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

# We create the function `get_processed_data` to load the housing data, normalize it, 
# and finally split it into train and test datasets:


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

# This function performs the following tasks:

# 1. Downloads the housing data. The original size of the data is 505 rows and 14 columns.
# 2. Loads the data as a 14x505 matrix. This is the shape that Flux expects.
# 3. Splits the data into features and a target. Notice that the 14th row corresponds to the target for each example.
# 4. Normalizes the data. For more information on normalizing data, see [How to Use StandardScaler and MinMaxScaler Transforms in Python](https://machinelearningmastery.com/standardscaler-and-minmaxscaler-transforms-in-python/).  
# 5. Splits the data into train and test datasets.
    

# ## Model
# We use a struct to define the model’s parameters. 
# It contains an array for holding the weights *W* and a vector for the bias term *b*:

# Also, we create the function `predict` to compute the model’s output:

model = Dense(13=>1)

# Notice that the function `predict` takes as an argument the model struct we defined above.

# ## Loss function

# The most commonly used loss function for Linear Regression is Mean Squared Error (MSE). 
# We define the MSE function as:

meansquarederror(ŷ, y) = sum((ŷ .- y).^2)/size(y, 2)

# **Note:** An implementation of the MSE function is also available in 
# [Flux](https://fluxml.ai/Flux.jl/stable/models/losses/#Flux.Losses.mse).

# ## Train function
# Finally, we define the `train` function so that the model learns the best parameters (*W* and *b*):


function train()
    ## Initialize the Hyperparamters
    
    ## Load the data
    data = get_processed_data()
        
    loss(model, x, y) = mean(abs2.(model(x) .- y));

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

# The function above initializes the model’s parameters *W* and *b* randomly. 
# Then, it sets the learning rate η and θ as a 
# [params object](https://fluxml.ai/Flux.jl/stable/training/training/#Flux.params) 
# that points to  W and b. Also, it sets a 
# [custom training loop](https://fluxml.ai/Flux.jl/stable/training/training/#Custom-Training-loops) 
# which is the [Gradient descent algorithm](https://en.wikipedia.org/wiki/Gradient_descent). 
# Finally, it computes the MSE for the test set.

# ## Run the example 
# We call the `train` function to run the Housing data example:

cd(@__DIR__)
train()
