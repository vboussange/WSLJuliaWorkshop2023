## Exercises
### Arrays 
1. Create a 2D array of integers called `my_array` with dimensions 3x4 and initialize it with random numbers between 1 and 10. 
2. Print the entire array. 
3. Print the element in the second row and third column. 
4. Print the first two rows of the array. 
5. Print the last two columns of the array. 
6. Replace the element in the second row and third column with the value 20. 
7. Calculate the sum of all the elements in the array. 
8. Calculate the mean of each column of the array.
### DataFrames 
1. Create a DataFrame called `my_df` with columns "name", "age", and "gender" and the following 

| name | age | gender |
| - | - | - |
| Alice | 25 | F |
| Bob | 32 | M |
| Charlie | 47 | M | 
| Denise | 18 | F |

1. Print the entire DataFrame. 
2. Print only the "name" column of the DataFrame. 
3. Print only the rows of the DataFrame where the age is greater than 30. 
4. Add a new column to the DataFrame called "score" with the following

|score|
|-|
85
91
76
92 

5. Calculate the mean age of the people in the DataFrame. 
6. Calculate the maximum score in the DataFrame.


### Loading files 
1. Download the "iris.csv" file from the following link: [https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv](https://raw.githubusercontent.com/uiuc-cse/data-fa14/gh-pages/data/iris.csv) 
2. Load the data from the file into a DataFrame called `iris_df`. 
3. Print the entire DataFrame. 
4. Print only the "Species" column of the DataFrame. 
5. Print only the rows of the DataFrame where the "Petal.Length" is greater than 5. 
6. Calculate the mean of each column of the DataFrame. 
7. Save the DataFrame to a new CSV file called "new_iris.csv".

### Plotting with DataFrames 
1. Load the `CSV` package. 
2. Import the "iris.csv" dataset using the `CSV.read()` function. 
3. Use the `describe()` function to get a summary of the data. 
4. Use the `filter()` function to create a new DataFrame containing only the rows where the "species" column is equal to "setosa". 
5. Use the `Plots` package to create a scatter plot of the "sepal_length" column on the x-axis and the "sepal_width" column on the y-axis for the filtered DataFrame.
6. Add a title to the plot and label the x and y axes. 
7. Save the plot to a file using the `savefig()` function.
