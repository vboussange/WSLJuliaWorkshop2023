using Dates
using CSV
using DataFrames

cd(@__DIR__)
include("src/regression_functions.jl")

csv_files = ["species1.csv", "species2.csv"]

df_results = DataFrame(species_name = [], slope = [], pval = [])

for cf in csv_files
    println("processing ", cf)
    result = linear_regression(joinpath("data", cf))
    push!(df_results, (cf, result...))
end

dir_results = joinpath("results", string(today()))
isdir(dir_results) ? nothing : mkdir(dir_results)
CSV.write(joinpath(dir_results, "linear_regression.csv"), df_results)
println("results saved")
