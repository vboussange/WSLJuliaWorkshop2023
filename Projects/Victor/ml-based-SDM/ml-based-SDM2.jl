using Rasters, GBIF2, Plots, DataFrames
ENV["RASTERDATASOURCES_PATH"] = "/Users/victorboussange/ETHZ/projects/raster_data"


# download presence data from gbif
species_name = "Passer montanus"
country = :CH
obs = GBIF2.occurrence_search(species_name, country=country, hasCoordinate=true, limit=4000)
coords = collect((r.decimalLongitude, r.decimalLatitude) for r in obs)

# load environmtal variable raster
env_var = RasterStack(CHELSA{BioClim}, (1, 3, 7, 12))[Band(1)]
# retrieve environmtal variable at presence coordinates
presence_data = DataFrame(extract(env_var, coords))
y = ones(size(presence_data,1))

# cropping the raster
using Downloads, Shapefile, DataFrames
# Download a borders shapefile
ne_url = "https://github.com/nvkelso/natural-earth-vector/raw/master/10m_cultural/ne_10m_admin_0_countries"
shp_url, dbf_url  = ne_url * ".shp", ne_url * ".dbf"
shp_name, dbf_name = "country_borders.shp", "country_borders.dbf"
# isfile(shp_name) || Downloads.download(shp_url, shp_name)
# isfile(dbf_url) || Downloads.download(dbf_url, dbf_name)

# Load the shapes for world countries
countries = Shapefile.Table(shp_name) |> DataFrame
CHE_polygon = countries[countries.ADM0_A3 .== "CHE", :geometry]

# we need to generate pseudo absences. here is a python script to do that
min_lat, max_lat = minimum(obs.decimalLatitude), maximum(obs.decimalLatitude)
min_long, max_long = minimum(obs.decimalLongitude), maximum(obs.decimalLongitude)

using Distributions
num_pseudo_absences = size(obs, 1)
pseud_absence_coords = [(rand(Uniform(min_lat, max_lat)), rand(Uniform(min_long, max_long))) for i = 1:num_pseudo_absences]

pseud_absence_data = DataFrame(extract(env_var, pseud_absence_coords))


# using Metal
device_array = cpu

train_data_balanced = vcat(presence_data, pseud_absence_data)[:,2:end] |> Array{Float32,2} |> adjoint |> MtlArray
y = vcat(y, zeros(size(train_data_balanced,2))) |> Vector{Float32} |> adjoint |> MtlArray


#=
# create pseudo-absence data by randomly sampling from within the range of our latitude and longitude values
num_pseudo_absences = train_data['presence'].sum()  # number of presence locations in our dataset
min_lat, max_lat = data['latitude'].min(), data['latitude'].max()
min_lon, max_lon = data['longitude'].min(), data['longitude'].max()

pseudo_absences = pd.DataFrame({
    'latitude': np.random.uniform(low=min_lat, high=max_lat, size=num_pseudo_absences),
    'longitude': np.random.uniform(low=min_lon, high=max_lon, size=num_pseudo_absences),
    'presence': 0
})

# concatenate the pseudo-absence data with our original data to create a balanced training dataset
balanced_train_data = pd.concat([train_data, pseudo_absences])

# shuffle the data before training
balanced_train_data = balanced_train_data.sample(frac=1, random_state=1)

# preprocess the balanced training data
balanced_train_features = balanced_train_data[['latitude', 'longitude']]
balanced_train_labels = tf.keras.utils.to_categorical(balanced_train_data['presence'])
balanced_train_features = min_max_scaler.transform(balanced_train_features)


Here is an other snippet

```
import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, roc_auc_score
from sklearn.utils import resample
from pygbif import occurrences

# Load GBIF data
gbif_data = occurrences.search(taxonKey=12345) # Replace 12345 with the taxon key of your species

# Extract presence data
presence_data = pd.DataFrame(gbif_data['results'])[['decimalLatitude', 'decimalLongitude']]
presence_data['presence'] = 1

# Generate pseudo-absences
min_lat, max_lat = presence_data['decimalLatitude'].min(), presence_data['decimalLatitude'].max()
min_lon, max_lon = presence_data['decimalLongitude'].min(), presence_data['decimalLongitude'].max()
pseudo_absences = pd.DataFrame({
    'decimalLatitude': np.random.uniform(min_lat, max_lat, size=len(presence_data))),
    'decimalLongitude': np.random.uniform(min_lon, max_lon, size=len(presence_data))})
pseudo_absences['presence'] = 0

# Combine presence and pseudo-absence data
data = pd.concat([presence_data, pseudo_absences])

# Load CHELSA environmental data
environmental_data = pd.read_csv('chelsa_environmental_data.csv')

# Merge environmental data with occurrence data
data = pd.merge(data, environmental_data, on=['decimalLatitude', 'decimalLongitude

```
=#

# plotting

using Plots
using MLUtils
env_var_CHE = trim(mask(env_var; with=CHE_polygon); pad=10)
plot(env_var_CHE)

# building a data generator function
split_at = 0.7
train_idx, test_idx = splitobs(1:size(train_data_balanced,2), at=split_at)

X_train, y_train = train_data_balanced[:, train_idx], y[:, train_idx]
X_test, y_test = train_data_balanced[:, test_idx], y[:, test_idx]

# Scale features


# building a neural net
using Flux

# Define model architecture
model = Chain(
    Dense(size(train_data_balanced, 1), 10, relu),
    Dense(10, 1),
    softmax)


# testing model
model(X_train)
y
binarycrossentropy(model(X_train), y_train)


# Train model
import Flux.Data:DataLoader
# using cross entropy
using Flux.Losses

batch_size = 32
num_epochs = 50
opt_state = Flux.setup(Adam(), model)

# Training loop, using the whole data set 1000 times:
losses = []
for epoch in 1:num_epochs
    for batch in Flux.Data.DataLoader((X_train, y_train), batchsize=batch_size, shuffle=true)
        _l, grads = Flux.withgradient(model) do m
            # Evaluate model and loss inside gradient context:
            binarycrossentropy(model(X_train), y_train)
        end
        Flux.update!(opt_state, model, grads[1])
        push!(losses, _l)  # logging, outside gradient context
        # Evaluate model on test set
    end
    acc = binarycrossentropy(model(X_test), y_test')
    println("Epoch $epoch, accuracy: $acc, loss: $(losses[end])")
end