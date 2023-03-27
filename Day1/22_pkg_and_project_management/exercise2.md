# Exercise: managing a Julia research project

In this exercise, we'll explore how the relationship between the size of a tree and the amount of carbon it stores changes from one species to the other. We'll use a simple linear regression model to estimate the slope of the relationship, and compare it throughout the species investigated.

### Requirements

#### Part 1: Package management

- Activate your environment, and install the following dependencies
  - `GLM`
  - `DataFrames`
  - `CSV`

#### Part 2: project management

- Create a new project directory and set up the following directory structure

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

- In the `src/regression_functions.jl`, create a function `linear_regression` that takes in a string corresponding to the location of a CSV file, and outputs the slope associated p-value of the linear regression between `tree_size` and `carbon_content` variables in the CSV.

> **Hints**
> 
> The slope of a `GLM` model may be retrieved as   
>
> `slope = GLM.coeftable(model).cols[1][2]`
>
> And its p-value as 
> 
> `pval = GLM.coeftable(model).cols[4][2]`
    
- Create a unit test for `linear_regression` in `test/regression_functions.jl`
  - Use the `Test` module

- In `my-analysis.jl` file, write a Julia script that
  - loads the necessary packages
  - loads the functions in `src/regression_functions.jl` 
  - creates an empty `DataFrame`
    - ```julia
      df_results = DataFrame(species_name = [], slope = [], pval = [])
      ```
  - loops through the CSV files, runs for each a linear regression using `linear_regression`, and pushes the results to the `DataFrame`
    - Make sure to print some logging information, e.g. `println("processing ", csv_filename)`
  - exports the dataframe as a CSV file in the result folder

- Use a shell script to run `my-analysis.jl`

## Solutions
You may find the solutions in the `Day1/23_practical-guidelines/my_project_solutions` folder.