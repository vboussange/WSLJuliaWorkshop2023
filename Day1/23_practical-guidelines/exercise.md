# Exercise: managing a Julia research project

In this exercise, we'll explore the relationship between the size of a tree and the amount of carbon it stores for two different tree species. We'll use a simple linear regression model to estimate the slope and intercept of the relationship.

### Project Structure

Create a new project directory and set up the following directory structure

```css
my_project/
├── src/
│   └── regression_functions.jl
├── tests/
│   └── test_regression_functions.jl
├── data/
│   └── species1.csv
│   └── species2.csv
├── results/
├── Manifest.toml
├── Project.toml
├── .gitignore
├── run_code.sh
└── my-analysis.jl
```



You will need to create the `src/`, `tests/`, `data/`, and `results/` directories, as well as the `Manifest.toml`, `Project.toml`, `.gitignore`, `run_code.sh`, and `my-analysis.jl` files.

The `data/` directory should contain a file called `fish_data.csv`, which contains the following columns: 
- `weight`: the weight of the fish in grams 
- `length`: the length of the fish in centimeters

You can use the `CSV.jl` package to load the data from the CSV file.

The `src/` directory should contain two files: 
- `data_loader.jl`: a file that contains a function called `load_data()` that loads the fish data from the CSV file and returns it as a DataFrame. 
- `regression_functions.jl`: a file that contains a function called `run_regression()` that performs linear regression on the fish data using the `StatsModels.jl` package and returns the regression model.

The `tests/` directory should contain two files: 
- `test_data_loader.jl`: a file that tests the `load_data()` function to make sure that it is correctly loading the fish data. 
- `test_regression_functions.jl`: a file that tests the `run_regression()` function to make sure that it is correctly performing linear regression on the fish data.

The `results/` directory should be empty, but this is where you will save the results of your analysis.

The `Manifest.toml` and `Project.toml` files are used to manage the dependencies of your project. You can add dependencies using the `] add` command in the Julia REPL.

The `.gitignore` file specifies which files and directories should be ignored by version control. You should add any automatically generated files and any files that contain sensitive information to this file.

The `run_code.sh` script is a shell script that you can use to run your Julia scripts.

The `my-analysis.jl` file is the main script that you will be writing to perform the linear regression analysis.
### Requirements

Your analysis script should do the following: 
1. Load the fish data using the `load_data()` function from `src/data_loader.jl`. 
2. Perform linear regression on the fish data using the `run_regression()` function from `src/regression_functions.jl`.
3. Print out the summary of the regression model. 
4. Save the following information to a file called `fish_regression_output.txt` in the `results/` directory:
- The coefficients of the regression model.
- The R-squared value of the regression model.

Your unit tests should do the following:
1. Test

Person: 
- Please continue

ChatGPT: 
- Your unit tests should do the following: 
1. Test that the `load_data()` function from `src/data_loader.jl` correctly loads the fish data. 
2. Test that the `run_regression()` function from `src/regression_functions.jl` correctly performs linear regression on the fish data.

Your test functions should use the `Test.jl` package to write the tests. For example, a test for the `load_data()` function might look like this:

```julia
using Test
using DataFrames

include("src/data_loader.jl")

function test_load_data()
    data = load_data()
    @test typeof(data) == DataFrame
    @test size(data, 1) == 100
    @test size(data, 2) == 2
    @test all(names(data) .== ["weight", "length"])
end
```



This test checks that the `load_data()` function returns a `DataFrame` with the correct number of rows and columns, and that the column names are correct.
### Tips

Here are some tips to help you complete this exercise: 
- Use the `Pkg` package to manage your project dependencies. You can use the `] add` command in the Julia REPL to add packages to your project. 
- Use the `CSV.jl` package to load the fish data from the CSV file. 
- Use the `StatsModels.jl` package to perform linear regression on the fish data. 
- Use the `DataFrames.jl` package to work with the fish data as a `DataFrame`. 
- Use the `Test.jl` package to write your unit tests.
### Deliverables

Your deliverables for this exercise are: 
- The completed project structure, including the `src/`, `tests/`, `data/`, and `results/` directories, as well as the `Manifest.toml`, `Project.toml`, `.gitignore`, `run_code.sh`, and `my-analysis.jl` files. 
- The `load_data()` function in `src/data_loader.jl`. 
- The `run_regression()` function in `src/regression_functions.jl`. 
- The `test_load_data()` function in `tests/test_data_loader.jl`. 
- The `test_run_regression()` function in `tests/test_regression_functions.jl`.

To submit your deliverables, zip up the entire project directory and upload it to the submission platform.
