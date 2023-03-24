using CSV
using GLM

function linear_regression(csv_filename)
    # Read in data
    df = CSV.File(csv_filename) |> DataFrame

    # Perform linear regression
    model = lm(@formula(tree_size ~ carbon_content), df)
    
    pval = GLM.coeftable(model).cols[4][2]
    slope = GLM.coeftable(model).cols[1][2]


    return slope, pval
end
