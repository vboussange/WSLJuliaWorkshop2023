# Benchmarking PiecewiseInference.jl against ApproxBayes.jl and Turing.jl

![](https://github.com/vboussange/PiecewiseInference.jl/raw/main/docs/animated.gif)


## Project description and objectives
Mechanistic ecosystem models have the potential to predict the response of ecosystems to global change by simulating the underlying biological and physical processes. However, their predictive power is often limited due to issues with parameter estimation and model inaccuracies, which are challenging to overcome. Inverse modelling techniques can improve parameter estimation and model selection, but they are often computationally expensive and challenging to apply to ecosystem models. Here, we propose a project to benchmark a recent inverse modelling machine learning framework for ecosystem modelling, **PiecewiseInference.jl**, against two more standard approaches, **ApproxBayes.jl** and **Turing.jl**. The outcome of this project may be integrated in the PiecewiseInference.jl documenation. By contributing to the documentation of PiecewiseInference.jl, this project provides a great opportunity to learn how to contribute to an open-source package while gaining experience in using Julia packages for modeling and data analysis in biodiversity and earth sciences. 

### Project Objectives
The objective of the project is to **benchmark** the performance of PiecewiseInference.jl against two standard approaches, ApproxBayes.jl and Turing.jl, for fitting mechanistic models to ecological time series. The participants will use a simple 3 species ecosystem model to generate time series with different noise levels and compare the accuracy and computational time of the methods. The project aims to provide insights into the performance of different methods for fitting mechanistic models to ecological time series and contribute to the development and improvement of PiecewiseInference.jl.

### Methodology

#### Get to know the required packages
Install the required packages
- [ApproxBayes.jl](https://github.com/marcjwilliams1/ApproxBayes.jl): A package for approximate Bayesian computation.
- [Turing.jl](https://turing.ml): A package for Bayesian computation.
- [EcoEvoModelZoo.jl](https://github.com/vboussange/EcoEvoModelZoo.jl): A package containing various ecological models that can be used for teaching and research.
- [PiecewiseInference.jl](https://github.com/vboussange/PiecewiseInference.jl): A machine learning framework for inverse ecosystem modelling.

`PiecewiseInference` and `EcoEvoModelZoo` are unregistered packages - check out their github repository to understand how to install it.

#### Resources
- Rapidly scan through the following tutorials, that provide hands-on explanations on how to use each of the inverse modelling packages
  - [A cool Julia tutorial on approximate Bayesian computation with ApproxBayes.jl](https://vboussange.github.io/post/abc_inference/).
  - [A cool Julia tutorial on Bayesian inference with Turing.jl](https://turinglang.org/v0.24/tutorials/10-bayesian-differential-equations/).
  - [A cool Julia tutorial on how to use PiecewiseInference with a 5 species ecosystem model.](https://vboussange.github.io/post/piecewiseinference/)
- [Some nice benchmarks from the SciML ecosystem](https://docs.sciml.ai/SciMLBenchmarksOutput/stable/BayesianInference/DiffEqBayesFitzHughNagumo/)
  - In particular, check this [benchmark](https://docs.sciml.ai/SciMLBenchmarksOutput/stable/BayesianInference/DiffEqBayesLorenz/)


#### Generate time series data and functions to evaluate the three methods

Similarly to the [PiecewiseInference tutorial](https://vboussange.github.io/post/piecewiseinference/), participants should generate time series data using the 3 species ecosystem model with different noise levels, and contaminate it with noise. The benchmark should be based upon this generated time series.

```julia
data = simulate(model) |> Array
noise_level = 0.1
data = data .* exp.(0.1 * randn(size(data)))
display(plot_time_series(data))
```

Participants should then write three different function, `approxBayes_fit`, `turing_fit`, and `piecewise_inference_fit`, which take as arguments a model and a dataset and return the model parameters inferred with the corresponding method.

#### Evaluate the methods


To evaluate the three different methods, participants are invited to use different criteria for assessing the performance of each method. 

1. **Accuracy**: Comparing the estimated parameter values with the true parameter values used to generate the simulated data. 
2. **Goodness of fit**: Calculating metrics such as root mean squared error (RMSE), mean absolute error (MAE), coefficient of determination (R²), and Akaike Information Criterion (AIC).
3. **Precision**: Calculating the variance of the estimated parameter values across multiple runs of each method. 
4. **Efficiency**: Measuring the time and memory required for each method to estimate the parameter values. 
5. **Robustness**: Simulating different types of noise (e.g., measurement error, sampling error) and data incompleteness (e.g., missing data points) and comparing the performance of each method under these conditions.


#### Documenting the results and creating a pull request in `PiecewiseInference`

After completing the project, participants are expected to document their results and create a pull request in the PiecewiseInference.jl repository. The pull request should include the benchmark results, including the code used to generate the results and a brief summary of the findings. The documentation should be clear and easy to understand, with appropriate figures and tables to illustrate the results. The results will be reviewed by the developers of PiecewiseInference.jl and, if deemed appropriate, integrated into the documentation of the package. This is a great opportunity for participants to contribute to an open source project and showcase their skills to the broader scientific community.
