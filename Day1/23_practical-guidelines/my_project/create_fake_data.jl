using CSV
using DataFrames
using Random
cd(@__DIR__)

# set the random seed for reproducibility
Random.seed!(1234)

# dataset number 1
# generate random data for trees
tree_sizes = rand(10:50, 100)
carbon_content = round.(rand(0.1:0.05:0.5, 100), digits=2)

# create a DataFrame
trees_df = DataFrame(tree_size = tree_sizes, carbon_content = carbon_content)

# write the data to a CSV file
CSV.write("data/species1.csv", trees_df)

# dataset number 2
# generate random data for trees
tree_sizes = rand(10:50, 100)
carbon_content = round.(tree_sizes .* rand(0.01:0.05, 100), digits=2)

# create a DataFrame
trees_df = DataFrame(tree_size = tree_sizes, carbon_content = carbon_content)

# write the data to a CSV file
CSV.write("data/species2.csv", trees_df)