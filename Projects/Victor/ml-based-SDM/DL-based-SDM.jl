cd(@__DIR__)
using Pkg
Pkg.activate(".")
using Rasters
using GBIF2
using Plots
using DataFrames
using JLD2


# download presence data from GBIF
function download_GBIF_data(species_name)
    obs = GBIF2.occurrence_search(species_name, 
                                    decimalLatitude = (45., 48.),
                                    decimalLongitude = (5., 11.), 
                                    hasCoordinate=true, limit=4000)
    return obs
end

function generate_presence_data(obs, env_var)
    coords = collect((r.decimalLongitude, r.decimalLatitude) for r in obs)

    # retrieve environmtal variable at presence coordinates
    presence_data = DataFrame(extract(env_var, coords))
    presence_data[!, :occcurence] = ones(size(pseud_absence_data,1))

    return presence_data
end

using Distributions
function generate_absence_data(obs, env_var)
    # we need to generate pseudo absences. here is a python script to do that
    min_lat, max_lat = minimum(obs.decimalLatitude), maximum(obs.decimalLatitude)
    min_long, max_long = minimum(obs.decimalLongitude), maximum(obs.decimalLongitude)

    num_pseudo_absences = size(obs, 1)
    pseud_absence_coords = [(rand(Uniform(min_long, max_long)), rand(Uniform(min_lat, max_lat))) for i = 1:num_pseudo_absences]

    pseud_absence_data = DataFrame(extract(env_var, pseud_absence_coords))
    pseud_absence_data[!, :occcurence] = zeros(size(pseud_absence_data,1))
    return pseud_absence_data
end

scaledat(x) = (x .- mean(x, dims=2)) ./ std(x, dims=2)

using Random
function generate_training_data(species_name)
    obs = download_GBIF_data(species_name)
    # load environmental variable raster
    env_var = RasterStack("data/CH_CHELSA_BIOCLIM/")[Band(1)]
    presence_data = generate_presence_data(obs, env_var)
    pseud_absence_data = generate_absence_data(obs, env_var)
    # removing the coordinate column
    data_df = vcat(presence_data, pseud_absence_data)
    dropmissing!(data_df)
    shuffle!(data_df)
    predictors = data_df[:,2:end-1] |> Array{Float32,2} |> adjoint
    predictors = scaledat(predictors)
    y = data_df.occcurence |> Vector{Float32} |> adjoint
    
    return predictors, y
end

using Plots
using MLUtils
using Flux.Losses
using Flux
import Flux.Data:DataLoader

function train(model, preds, y)
    # building a data generator function
    split_at = 0.7
    train_idx, test_idx = splitobs(1:length(y), at=split_at)

    X_train, y_train = preds[:, train_idx], y[:, train_idx]
    X_test, y_test = preds[:, test_idx], y[:, test_idx]

    # Scale features

    # testing model
    model(X_train)
    y
    binarycrossentropy(model(X_train), y_train)

    batch_size = 32
    num_epochs = 50
    opt_state = Flux.setup(Adam(), model)

    # Training loop, using the whole data set 1000 times:
    losses = []
    dtrain = Flux.Data.DataLoader((X_train, y_train), batchsize=batch_size, shuffle=true)

    acc = binarycrossentropy(model(X_test), y_test)
    l = binarycrossentropy(model(X_train), y_train)
    println("Epoch 0, accuracy: $acc, loss: $l")
    for epoch in 1:num_epochs
        for (x, y) in dtrain
            grads = gradient(model) do m
                # Evaluate model and loss inside gradient context:
                binarycrossentropy(m(x), y)
            end
            Flux.update!(opt_state, model, grads[1])
            # Evaluate model on test set
        end
        acc = binarycrossentropy(model(X_test), y_test)
        l = binarycrossentropy(model(X_train), y_train)
        println("Epoch $epoch, accuracy: $acc, loss: $l")
    end
    return model
end

species_name = "Passer montanus"
preds, y = generate_training_data(species_name)

# Define model architecture
model = Chain(Dense(size(preds, 1), 64, relu),
                BatchNorm(64),
                Dense(64, 32, relu),
                BatchNorm(32),
                Dense(32, 1, sigmoid),)

train(model, preds, y)