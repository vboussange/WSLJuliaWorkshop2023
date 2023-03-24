# Analyzing Mammal Data

In this exercise, you will be analyzing data on the body mass and basal metabolic rate (BMR) of mammals. The data is stored in a CSV file located in the `data/` directory. You will be writing Julia code to import the data, analyze it, and save the results to a file in the `results/` directory.
#### Step 1: Import the Data 
1. Create a new Julia script file in the root of your project directory and name it `analyze_mammal_data.jl`. 
2. At the top of your script, add the following line to import the `CSV.jl` package: `using CSV` 
3. Import the mammal data from the CSV file `data/mammal_data.csv` into a `DataFrame` using the `CSV.read()` function from the `CSV.jl` package. Assign the resulting `DataFrame` to a variable named `mammal_data`.
#### Step 2: Analyze the Data 
1. Write a function named `mean_body_mass` in a file located in the `src/` directory. This function should take a `DataFrame` as an argument and return the mean body mass of all the mammals in the `DataFrame`. 
2. Write a function named `mean_bmr` in the same file as `mean_body_mass`. This function should take a `DataFrame` as an argument and return the mean basal metabolic rate of all the mammals in the `DataFrame`. 
3. In your `analyze_mammal_data.jl` script, import the `mean_body_mass()` and `mean_bmr()` functions from the file in the `src/` directory using the `include()` function. 
4. Use the `mean_body_mass()` and `mean_bmr()` functions to calculate the mean body mass and mean basal metabolic rate of the mammals in the `mammal_data` `DataFrame`. Assign the results to the variables `mean_mass` and `mean_bmr`, respectively.
#### Step 3: Save the Results 
1. Create a new directory in the root of your project directory and name it `results`. 
2. Create a new file in the `results/` directory named `mammal_data_analysis.txt`. 
3. Write the following text to the file:

```php
Mean Body Mass: <mean_mass>
Mean Basal Metabolic Rate: <mean_bmr>
```



Replace `<mean_mass>` and `<mean_bmr>` with the values you calculated in Step 2.
#### Step 4: Run Your Code 
1. In the root of your project directory, create a new shell script file named `run_analysis.sh`. 
2. In `run_analysis.sh`, add the following command to run your Julia script:

```
Copy code
julia analyze_mammal_data.jl
``` 
3. Make `run_analysis.sh` executable by running the following command in your terminal:

```bash
chmod +x run_analysis.sh
``` 
4. Run `run_analysis.sh` in your terminal to execute your Julia script and generate the `results/mammal_data_analysis.txt` file.

Congratulations! You have successfully analyzed mammal data using Julia and your project structure.