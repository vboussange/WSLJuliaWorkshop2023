## Exercises
```julia
cd(@__DIR__)
using Pkg; Pkg.activate(".")
```

### Iris dataset

### Loading files 
1. Download the "iris.csv" file from the following link: [https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv](https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv). Save it in a file `iris_data.csv`
```julia
using Downloads

iris_data_filename = "iris_data.csv"
Downloads.download("https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv", iris_data_filename)
```

2. Load the data from the file into a `DataFrame` called `iris_df`.
```julia
using CSV, DataFrames
iris_df = DataFrame(CSV.File(iris_data_filename))
```

3. Print the entire DataFrame. 

```julia
println(iris_df)
```
4. Print only the "species" column of the DataFrame. 
```julia
println(iris_df[:,[:species]])
```

5. Print only the rows of the `DataFrame` where the "petal_length" is greater than 5. 

```julia
println(iris_df[iris_df.petal_length .> 5., :])
```

1. Create a new `DataFrame`, which contains the mean and standard deviation of sepal length for each species

```julia
using Statistics
df_g = groupby(iris_df, :species)
df_stats = combine(df_g, :sepal_length => mean, :sepal_length => std)
println(df_stats)
```

2. Save the DataFrame to a new CSV file called "new_iris.csv".

```julia
CSV.write("new_iris.csv", df_stats)
```

### Plotting with DataFrames 
1. Load the `CSV` package. 
2. Import the "iris.csv" dataset using the `CSV.read()` function. 
3. Use the `describe()` function to get a summary of the data. 
4. Use the `filter()` function to create a new DataFrame containing only the rows where the "species" column is equal to "setosa". 
5. Use the `Plots` package to create a scatter plot of the "sepal_length" column on the x-axis and the "sepal_width" column on the y-axis for the filtered DataFrame.
6. Add a title to the plot and label the x and y axes. 
7. Save the plot to a file using the `savefig()` function.

