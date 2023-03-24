# # Housing data

# In this example, we create a linear regression model that predicts housing data. 
# It replicates the housing data example from the [Knet.jl readme](https://github.com/denizyuret/Knet.jl). 
# Although we could have reused more of Flux (see the MNIST example), the library's abstractions are very 
# lightweight and don't force you into any particular strategy.

# A linear model can be created as a neural network with a single layer. 
# The number of inputs is the same as the features that the data has. 
# Each input is connected to a single output with no activation function. 
# Then, the output of the model is a linear function that predicts unseen data. 

# ![singleneuron](img/singleneuron.svg)

# Source: [Dive into Deep Learning](http://d2l.ai/chapter_linear-networks/linear-regression.html#from-linear-regression-to-deep-networks)

# To run this example, we need the following packages:

using Flux
using Flux: gradient, train!
using Flux.Optimise: update!
using DelimitedFiles, Statistics
using Parameters: @with_kw


# ## Data 

# We create the function `get_processed_data` to load the housing data, and normalize it.

function get_processed_data(split_ratio=0.1)
    isfile("housing.data") ||
        download("https://raw.githubusercontent.com/MikeInnes/notebooks/master/housing.data",
            "housing.data")

    rawdata = readdlm("housing.data")'

    ## The last feature is our target -- the price of the house.

    x = rawdata[1:13,:]
    y = rawdata[14:14,:]

    return [(x,y)]
end


# ## Model
# A Single dense layer with no activation

model = Dense(13=>1)

# ## Loss function

# The most commonly used loss function for Linear Regression is Mean Squared Error (MSE). 
# We define the MSE function as:

loss(model, x, y) = mean(abs2.(model(x) .- y));

# **Note:** An implementation of the MSE function is also available in 
# [Flux](https://fluxml.ai/Flux.jl/stable/models/losses/#Flux.Losses.mse).

# ## Train function
# Finally, we define the `train` function so that the model learns the best parameters (*W* and *b*):


function train()
    
    ## Load the data
    data = get_processed_data()

    ## Training
    opt = Flux.setup(Adam(), model)

    for epoch in 1:200
        if epoch % 50 == 1
            println("epoch = $epoch")
        end
        train!(loss, model, data, opt)
    end    

    # println(loss(model, data...))
end

# ## Run the example 
# We call the `train` function to run the Housing data example:

cd(@__DIR__)
train()
