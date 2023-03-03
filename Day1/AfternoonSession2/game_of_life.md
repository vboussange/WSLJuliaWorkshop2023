# The game of life

The **Game of Life** is a classic cellular automaton invented by John Conway. In this simulation, each cell on a grid can either be alive or dead, and they change states according to a set of rules. The rules are as follows:

- Any live cell with two or three live neighbors survives.
- Any dead cell with three live neighbors becomes a live cell.
- All other live cells die in the next generation. Similarly, all other dead cells stay dead.


Here is the code in Julia:

```julia
# Define the dimensions of the grid
width = 50
height = 50

# Initialize the grid with random values
grid = rand([0, 1], width, height)

# Define a function to count the number of live neighbors for each cell
function count_neighbors(grid, x, y)
    count = 0
    for i in -1:1
        for j in -1:1
            if i == 0 && j == 0
                continue
            end
            x_new = x + i
            y_new = y + j
            if x_new < 1 || x_new > size(grid, 1) || y_new < 1 || y_new > size(grid, 2)
                continue
            end
            count += grid[x_new, y_new]
        end
    end
    return count
end

# Define a function to update the grid for one generation
function update_grid(grid)
    new_grid = copy(grid)
    for i in 1:size(grid, 1)
        for j in 1:size(grid, 2)
            neighbors = count_neighbors(grid, i, j)
            if grid[i, j] == 1
                if neighbors < 2 || neighbors > 3
                    new_grid[i, j] = 0
                end
            else
                if neighbors == 3
                    new_grid[i, j] = 1
                end
            end
        end
    end
    return new_grid
end

# Run the simulation for 50 generations
for i in 1:50
    println("Generation $i:")
    show(grid)
    grid = update_grid(grid)
end
```

This code will initialize a random grid, count the number of live neighbors for each cell, update the grid according to the rules, and print out the grid for each generation. You can adjust the width, height, and number of generations by changing the values of width, height, and the for loop range, respectively.

Let's make it fancier with Plots.jl!

```julia
using Plots
# Create a plot of the initial grid
heatmap(grid, c=:Greys)

# Define a function to update the plot for one generation
function update_plot(grid)
    grid = update_grid(grid)
    heatmap(grid, c=:Greys)
end

# Animate the plot for 50 generations
animation = @animate for i in 1:50
    update_plot(grid)
end

# Display the animation
gif(animation, "game_of_life.gif", fps = 10)
```