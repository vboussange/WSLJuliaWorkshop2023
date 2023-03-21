# Hyper parameter optimization of a machine learning-based Species Distribution Model

## Project description and objectives
A Species Distribution Model (SDM) is a type of predictive modeling approach used in ecology and conservation biology to understand and predict the distribution of species in a particular geographic area. SDMs use statistical or machine learning methods to relate the occurrence or abundance of a species to environmental variables, such as temperature, precipitation, elevation, and land use. The model can then be used to predict the distribution of the species across the landscape, even in areas where the species has not been observed. SDMs are useful for understanding the factors that determine the distribution of species and for predicting how changes in the environment may impact the distribution of species in the future. Machine learning algorithms such as neural networks have shown great potential in building accurate SDMs. However, choosing the right hyperparameters for these models is crucial for their performance.

### Project Objective
The objective of this project is to build a species distribution model using a fully connected neural network, and fine-tune the neural network architecture, i.e. optimize the neural network hyperparameters. Different hyperparameter optimization strategies will be explored, including grid search and bayesian hyperparameter optimization. Further objectives may include feature selection, and constructing more elaborate models that can predict species communities.

### Methodology
The project can be divided into the following steps:

#### Data preparation

The first step is to gather the data required to build the SDM. The dataset should include information about the presence or absence of a species and environmental variables such as temperature, precipitation, and vegetation cover. The data should then be divided into training, validation, and testing sets. The ratio of data in each set should be decided based on the size of the dataset, but typically the training set should be larger than the validation and testing sets. It is important to ensure that the data in each set is representative of the overall dataset.


#### Building the neural network 
The next step is to build a fully connected neural network model using the Julia programming language. The neural network should include an input layer, one or more hidden layers, and an output layer. The participants should experiment with different architectures, including varying the number of hidden layers, neurons per layer, and activation functions.

#### Hyperparameter optimization

Hyperparameters of a neural network model are parameters that are not learned during training but are set by the user before training. The hyperparameters define the structure and behavior of the neural network and influence how the model learns from the input data. Some common hyperparameters of a neural network model include:

- Number of hidden layers: This defines the number of layers between the input and output layers of the neural network.
Number of neurons in each hidden layer: This defines the number of nodes or neurons in each hidden layer of the neural network.

- Activation function: This defines the mathematical function used to transform the output of each neuron in the neural network.

- Learning rate: This defines the step size or the rate at which the model updates the weights during training.

- Dropout rate: This defines the fraction of neurons in the neural network that are randomly dropped out during training to prevent overfitting.

Optimizing these hyperparameters can significantly improve the performance of the neural network and the accuracy of the model predictions. 
The participants can follow two approaches to optimize the hyperparameters of the neural network:

  - **a. Grid search** Grid search involves defining a grid of hyperparameters and evaluating the performance of the model for each combination of hyperparameters. The best combination of hyperparameters is selected based on the performance on the validation set. Participants should define a range of values for each hyperparameter and generate a grid of all possible combinations. The performance of the model should then be evaluated for each combination of hyperparameters. Participants should choose the combination of hyperparameters that gives the best performance on the validation set.

  - **b. Bayesian hyperparameter optimization** Bayesian optimization is a more sophisticated method that uses probabilistic models to explore the hyperparameter space efficiently. Bayesian optimization builds a probabilistic model of the objective function (in this case, the performance of the SDM on the validation set) and uses it to select the next set of hyperparameters to evaluate. Participants should define a prior distribution for each hyperparameter and use it to initialize a probabilistic model. The model should be updated iteratively by evaluating the performance of the model for different hyperparameter combinations. The next set of hyperparameters to evaluate should be selected based on the model's prediction of the best combination of hyperparameters. The optimization process should continue until a satisfactory performance is achieved. Participants are invited to use [Hyperopt.jl](https://github.com/baggepinnen/Hyperopt.jl).

## Useful information

- [A Conceptual Explanation of Bayesian Hyperparameter Optimization for Machine Learning](https://towardsdatascience.com/a-conceptual-explanation-of-bayesian-model-based-hyperparameter-optimization-for-machine-learning-b8172278050f)

### Some tips on how to choose a neural network architecture

- Start with a simple network: Start with a small number of neurons and layers, and gradually increase the complexity of the network if necessary. A simpler network is easier to train and less likely to overfit the training data. 
- Use a pre-existing architecture: Use a pre-existing architecture that has been proven to work well for similar problems. This can save time and ensure that the network architecture is appropriate for the problem. 
- Consider the size of the input and output: The number of neurons in the input layer should match the size of the input data, and the number of neurons in the output layer should match the number of output classes or the size of the output data. 
- Experiment with different architectures: Experiment with different architectures, such as adding or removing layers, changing the number of neurons in each layer, or changing the activation functions. This can help to find the optimal architecture for the problem. 
- *Regularization techniques*: Use regularization techniques such as dropout, L1 or L2 regularization, or early stopping to prevent overfitting and improve the generalization of the network. 
- Use cross-validation: Use cross-validation to evaluate the performance of the network and to avoid overfitting.

Overall, the number of neurons and layers in a neural network depends on the complexity of the problem, the amount of data available, and the desired level of accuracy. It is important to balance the complexity of the network with the simplicity and interpretability of the solution.

## Getting started

### Data cleaning
```julia
using DataFrames, CSV, RData, Raster

bird_occurrences = DataFrame(CSV.File("data/bird_presence.csv"))
species_names = names(bird_occurrences[:, Not([:x, :y, :KoordID])])
env_var = load("data/bird_extent_stack.rds")["values"]
env_var_bird = extract(env_var, bird_occurrences[!, [:x, :y]])
env_var_names = names(env_var_bird)
bird_data = hcat(bird_occurrences, env_var_bird)
bird_data = bird_data[:, [species_names..., env_var_names...]]
bird_data = dropmissing(bird_data)
```



Here's what the code does: 
1. Loads the bird occurrence data from a CSV file using `CSV.File` from the CSV.jl package. The `DataFrame` constructor is then used to create a data frame from the loaded data. 
2. Extracts the names of the species from the bird occurrence data frame using Julia's `Not` macro to exclude the `x`, `y`, and `KoordID` columns. 
3. Loads environmental data from an RData file using the `load` function from the RData.jl package. We then extract the values from the "values" field of the loaded R object. 
4. Extracts the values of the environmental data for the locations of the bird occurrences using the `extract` function from the Raster.jl package. 
5. Extracts the names of the environmental variables from the extracted environmental data. 
6. Combines the bird occurrence data and the environmental data into a single data frame using the `hcat` function from the DataFrames.jl package. 
7. Rearranges the columns of the combined data frame to have the species names first, followed by the environmental variable names. 
8. Removes any rows with missing values from the combined data frame using the `dropmissing` function from the DataFrames.jl package.


```julia
function plot_obs_occurrences(species_name, dataset)
    presence = dataset[dataset[!, Symbol(species_name)] .== 1, [:x, :y]]
    absence = dataset[dataset[!, Symbol(species_name)] .== 0, [:x, :y]]
    plot(presence, title = species_name, color = "darkgreen", seriestype = :scatter,
         markersize = 4, xlims = extrema(dataset[!, :x]), ylims = extrema(dataset[!, :y]),
         xlabel = "", ylabel = "")
    scatter!(absence, color = "red", markersize = 4)
end

species_names_selected = "Anthus.spinoletta"
plot_obs_occurrences(species_names_selected, bird_occurrences)
```



Here's what the code does: 
1. Defines a function `plot_obs_occurrences` that takes the species name and the dataset as arguments. 
2. Extracts the locations of the bird occurrences for the given species and separates them into two data frames: `presence` for the locations where the species is present and `absence` for the locations where it is absent. 
3. Plots the locations of the bird occurrences on a scatter plot using `plot` from the Plots.jl package. The `color` argument is used to set the color of the points, `markersize` sets the size of the points, `xlims` and `ylims` set the limits of the x and y axes, and `xlabel` and `ylabel` hide the axis labels. 
4. Adds the locations where the species is absent to the plot using `scatter!` from the Plots.jl package. 
5. Defines the selected species as a string. 
6. Calls `plot_obs_occurrences` function with the selected species name and the bird occurrence data frame as arguments.

```julia
function generators_builder(dataset, env_var_names, species_names;
                            proportion = 0.8, batch_size = 32)
    dataset = dataset[:, vcat(env_var_names, species_names)]
    split = initial_split(dataset, proportion)
    train_dataset = Matrix(training(split))
    validation_dataset = Matrix(testing(split))

    data_generator(dataset, x, y, batch_size) = function()
        rows = 1:nrow(dataset)
        if length(rows) < batch_size
            rows .= 1:nrow(dataset)
        end
        selected_rows_i = sample(1:length(rows), batch_size, replace=false)
        selected_rows = rows[selected_rows_i]
        x_values = zeros(batch_size, length(x))
        x_values[1:batch_size, :] = convert(Array{Float32}, dataset[selected_rows, x])
        y_values = zeros(batch_size, length(y))
        y_values[1:batch_size, :] = convert(Array{Float32}, dataset[selected_rows, y])
        rows = rows[setdiff(1:length(rows), selected_rows_i)]
        return (x_values, y_values)
    end

    train_generator = data_generator(train_dataset, env_var_names, species_names, batch_size)
    validation_generator = data_generator(validation_dataset, env_var_names, species_names, batch_size)

    return Dict("train" => train_generator, "validation" => validation_generator,
                "train.length" => nrow(train_dataset),
                "validation.length" => nrow(validation_dataset))
end
```

### Some useful chunks of code

#### MLP function generator
```julia
function init_NN(;npreds, 
    nhlayers = 1, # number of hiddel layers
    hls = npreds + 50, # hidden layer size
    activation # activation function
    )
    if nhlayers == -1
        nn = Flux.Chain(Dense(npreds, 1, activation))
    else
        hlayers = [Dense(hls, hls, activation) for _ in 1:nhlayers]
        nn = Flux.Chain(Dense(npreds, hls, tanh),
                        hlayers...,
                        Dense(hls, 1, activation))
    end
    return destructure(nn)
end
```
## Grid search

## Hyperparameter optimization

## Going further

Can you spot differences in architectures when trying to predict species communities?

## Acknowledgement
This project has been partly inspired by work from Theopile Sanchez and Shuo Zong.