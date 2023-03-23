using Test
using DataFrames
include(joinpath(@__DIR__, "..", "src", "regression_functions.jl"))

# set up a test data frame
df_test = DataFrame(tree_size = 1:0.1:10, carbon_content = 1:0.1:10)


@testset "linear_regression" begin 
    # write test data to a CSV file
    test_file = joinpath(@__DIR__, "test.csv")
    CSV.write(test_file, df_test)

    # call linear_regression function on test data
    result = linear_regression(test_file)
    
    # check that the result is a vector of length 2
    @test length(result) == 2
    
    # check that the coefficients are approximately equal to the expected values
    @test isapprox(result[2], 1., atol=1e-2)
    @test isapprox(result[1], 0., atol=1e-2)
end
