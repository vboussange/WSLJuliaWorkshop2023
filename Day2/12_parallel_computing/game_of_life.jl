using Markdown


md"""
# Exercise: parallelizing the Game of Life

Last Friday, you have succesfully coded the Game of Life in Julia.

Let's try to make this nice piece of code that you have written faster with multi-threading and multiprocessing!

"""


md"""
So that you do not have to rewrite things, we provide you with the functions `count_neighbors` and `update_plot` in the `utils.jl` file located in this folder. Load those functions.
"""
#sol include("utils.jl")


md"""
Remember, here is what the function `update_grid` looks like:
"""

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

md"""
Write a `update_grid_multithreading` function that runs the code in parallel, using the `Threads.@threads` utilty
"""

function update_grid_multithreading(grid)
    new_grid = copy(grid)
    Threads.@threads for i in 1:size(grid, 1)
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

md"""
Benchmark the function `update_grid_multithreading` against the `update_grid`. Use `BenchmarkTools` to do so. You may use the function `run_simul` provided below.
"""

function run_simul(update_fn)
    grid = rand([0, 1], width, height)
    for i in 1:50
        grid = update_fn(grid)
    end
end

using BenchmarkTools

@btime run_simul(update_grid_multithreading) # 1.299 ms (1663 allocations: 1.11 MiB)


@btime run_simul(update_grid) # 2.381 ms (103 allocations: 1000.16 KiB)




