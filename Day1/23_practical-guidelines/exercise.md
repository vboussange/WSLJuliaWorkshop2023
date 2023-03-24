# Exercise: managing a Julia research project

In this exercise, we'll explore how the relationship between the size of a tree and the amount of carbon it stores changes from one species to the other. We'll use a simple linear regression model to estimate the slope of the relationship, and compare it throughout the species investigated.

### Requirements

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

- Activate your environment, and install the following dependencies
  - `GLM`
  - `DataFrames`
  - `CSV`

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
    
> 
- Create a unit test for `linear_regression` in `tests/regression_functions.jl`
  - Use the `Test` module

- In `my-analysis.jl` file, write a Julia script that loops through the CSV files and runs for each a linear regression using `linear_regression`. The script should and save the results in a `DataFrame` which should look like 
```julia
df_results = DataFrame(species_name = [], slope = [], pval = [])
```
  - Make sure to print some logging information
  - Output the CSV in the result folder

## Solutions
You may find the solutions in the `Day1/23_practical-guidelines/my_project` folder.