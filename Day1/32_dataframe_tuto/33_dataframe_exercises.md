## Exercises



### DataFrames and Plotting with the Iris dataset

Download the "iris.csv" file from [here](https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv). Save it in a file `iris_data.csv`



Load the data from the file into a `DataFrame` called `iris_df`.



Print the entire DataFrame. 



Print only the "species" column of the DataFrame. 



Print the first 5 rows in the DataFrame.



Print only the rows of the `DataFrame` where the "petal_length" is greater than 5. 




Create a new `DataFrame`, which contains the mean and standard deviation of sepal length for each species




Save the DataFrame to a new CSV file called "new_iris.csv".




Provide statistics for the species `setosa`. You should create a new `DataFrame` called `iris_df_setosa` and use the `describe` function.



Create a scatter plot of the `sepal_length` column on the x-axis and the `sepal_width` column on the y-axis. Each species should have a different color.



Add a title to the plot and label the x and y axes. Then, Save the plot to a pdf file using the `savefig()` function.



### Analyzing GBIF dataset using DataFrames, Broadcasting, and Data Visualization

First, let's load GBIF data.



What are the columns of this dataframe? How many rows does it have?




Group occurrences by canton (`stateProvince`). Print all cantons where the birds where observed.



 Which canton has the most number of occurence?






Create a bar chart with `Plots.jl`, that shows the total number of observations for each canton





Drop the rows where the `decimalLongitude` or `decimalLatitude` is `missing`




Normalize the `decimalLongitude` and `decimalLatitude`, so that it scales between 0 and 1.

For this, construct a function `normalize`, that takes in a vector of floating points and a new normalized vector. This function should use the `.` operator.

> 🥳 Congrats! You are done with this session of exercises.
## Solutions

You may find solutions to these exercises [here](/Users/victorboussange/ETHZ/PostDoc_ELE/teaching/WSL_workshop_Julia/material/Day1/32_dataframe_tuto/33_dataframe_exercises_with_sols.jmd).

