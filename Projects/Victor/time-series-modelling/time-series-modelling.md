# Marine ecosystem time series modelling

## Project description
This project focuses on exploring various modelling techniques to analyze the marine ecosystem time series and to derive predictive insights. The project will cover several techniques, including autoregressive models, recurrent neural networks, and ordinary differential equation models. Participants will be given the opportunity to work with real-world data, conduct exploratory data analysis, develop and validate their models, and compare their results to state-of-the-art techniques. By the end of the project, participants will have gained practical experience with Julia and a deeper understanding of time series analysis, modelling techniques, and their applications in biodiversity and earth sciences.

#### Project Objectives
Data exploration and visualization: Load the fish abundance time series data into Julia and perform exploratory data analysis (EDA) to get a sense of the data's distribution, trends, and any patterns. Use visualization tools like Plots.jl or Gadfly.jl to plot the time series data and identify any possible relationships between the fish species.

- **Autoregressive models**: Implement and fit different autoregressive (AR) models to the time series data using the ARMA.jl package. Compare and contrast the performance of different AR models, such as AR(1), AR(2), and AR(p), using metrics like Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC).

- **Recurrent neural networks (RNNs)**: Build and train an RNN using the Flux.jl package to forecast future fish abundance based on the historical data. Evaluate the performance of the RNN model using metrics like Mean Squared Error (MSE) and Root Mean Squared Error (RMSE).

- **ODE models**: Develop an ODE model of the marine ecosystem that accounts for factors like predator-prey interactions, environmental factors, and fishing pressure. Use the DifferentialEquations.jl package to simulate the ODE model and compare the simulation results to the actual time series data. Tune the model parameters to achieve a better fit.

- **Ensemble modelling**: Combine the different models developed in steps 2-4 using an ensemble approach, such as stacking or bagging, to improve the overall forecasting accuracy. Evaluate the performance of the ensemble model using metrics like MSE, RMSE, and Mean Absolute Percentage Error (MAPE).

- **Visualization and interpretation**: Use visualization tools to plot the results of the different modelling techniques and interpret the findings. Discuss the strengths and limitations of each method and suggest possible future research directions.

Overall, this project provides an opportunity for participants to gain hands-on experience in using Julia to apply a range of modelling techniques to real-world data from marine ecosystems.

#### Methodology


## Useful information

- [A cool Julia tutorial on approximate Bayesian computation with ApproxBayes.jl](https://vboussange.github.io/post/abc_inference/). Can be used as a basis for using xxx
- [A cool Julia tutorial on Bayesian inference with Turing.jl](https://turinglang.org/v0.24/tutorials/10-bayesian-differential-equations/).

### How to choose neural network architecture

## Getting started

### Data cleaning

### Some useful chunks of code

#### MLP function generator

## Grid search

## Hyperparameter optimization

## Going further

Can you spot differences in architectures when trying to predict species communities?

## Acknowledgement

