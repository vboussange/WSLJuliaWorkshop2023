## Exercises
```julia
cd(@__DIR__)
using Pkg; Pkg.activate(".")
```

### Level 1: Iris dataset

Download the "iris.csv" file from [here](https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv). Save it in a file `iris_data.csv`
```julia
using Downloads

iris_data_filename = "iris_data.csv"
Downloads.download("https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv", iris_data_filename)
```

Load the data from the file into a `DataFrame` called `iris_df`.
```julia
using CSV, DataFrames
iris_df = DataFrame(CSV.File(iris_data_filename))
```

Print the entire DataFrame. 

```julia
println(iris_df)
```
Print only the "species" column of the DataFrame. 
```julia
println(iris_df[:,[:species]])
```

Print only the rows of the `DataFrame` where the "petal_length" is greater than 5. 

```julia
println(iris_df[iris_df.petal_length .> 5., :])
```

Create a new `DataFrame`, which contains the mean and standard deviation of sepal length for each species

```julia
using Statistics
df_g = groupby(iris_df, :species)
df_stats = combine(df_g, :sepal_length => mean, :sepal_length => std)
println(df_stats)
```

Save the DataFrame to a new CSV file called "new_iris.csv".

```julia
CSV.write("new_iris.csv", df_stats)
```

Provide statistics for the species `setosa`. You should create a new `DataFrame` called `iris_df_setosa` and use the `describe` function.
```julia
iris_df_setosa = iris_df[iris_df.species .== "setosa", :]
describe(iris_df_setosa)
```

Create a scatter plot of the `sepal_length` column on the x-axis and the `sepal_width` column on the y-axis. Each species should have a different color.
```julia
using PythonPlot
fig, ax = subplots(1)
cols = ["tab:blue", "tab:green", "tab:red"]
for (i, df) in enumerate(df_g)
    ax.scatter(df.sepal_length, df.sepal_width, c = cols[i], label=df.species[1])
end
display(fig)
```

Add a title to the plot and label the x and y axes. Then, Save the plot to a pdf file using the `savefig()` function.
```julia
ax.legend()
ax.set_xlabel("sepal_length")
ax.set_ylabel("sepal_width")
ax.set_title("Iris traits")
fig.savefig("iris.pdf", dpi=100)
```


