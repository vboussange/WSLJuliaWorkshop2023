using Markdown


md"""
# Exercise: parallelizing the Game of Life

Last Friday, you have succesfully coded the Game of Life in Julia.

Let's try to make this nice piece of code that you have written faster with multithreading and multiprocessing!

"""


md"""
So that you do not have to rewrite things, we provide you with the functions `count_neighbors` and `update_plot` in the `utils.jl` file located in this folder. Load those functions.
"""
include("utils.jl")


md"""
Remember, here is what the function `update_grid` looks like:
"""

function update_grid(grid)
    new_grid = similar(grid)
    for idx in CartesianIndices(grid)
        neighbors = count_neighbors(grid, idx)
        if grid[idx] == 1 && (neighbors < 2 || neighbors > 3)
            new_grid[idx] = 0
        elseif grid[idx] == 0 && neighbors == 3
            new_grid[idx] = 1
        else
            new_grid[idx] = grid[idx]
        end
    end
    return new_grid
end

md"""
Write a `update_grid_multithreading` function that runs the code in parallel, using the `Threads.@threads` utilty
"""

function update_grid_multithreading(grid)
    new_grid = copy(grid)
    Threads.@threads for idx in CartesianIndices(grid)
        neighbors = count_neighbors(grid, idx)
        if grid[idx] == 1 && (neighbors < 2 || neighbors > 3)
            new_grid[idx] = 0
        elseif grid[idx] == 0 && neighbors == 3
            new_grid[idx] = 1
        else
            new_grid[idx] = grid[idx]
        end
    end
    return new_grid
end

md"""
Benchmark the function `update_grid_multithreading` against the `update_grid`. Use `BenchmarkTools` to do so. You may use the function `run_simul` provided below.
"""
width = 100
height = 100
function run_simul(update_fn)
    grid = rand([0, 1], width, height)
    for i in 1:50
        grid = update_fn(grid)
    end
end

using BenchmarkTools

println("Testing `update_grid_multithreading`")
@btime run_simul(update_grid_multithreading) # 1.299 ms (1663 allocations: 1.11 MiB)

println("Testing `update_grid`")
@btime run_simul(update_grid) # 2.381 ms (103 allocations: 1000.16 KiB)

md"""
Let's now try to use multiprocessing. 
Load the `Distributed` function and add some processes. Print the number of processes available.
"""
using Distributed
nprocs()
addprocs()
nprocs()


md"""
Write a `update_grid_multiprocessing` function.
Apply the `@everywhere` macro to the function `count_neighbors`.
"""
@everywhere function count_neighbors(grid, idx)
    count = 0
    for n in CartesianIndices((-1:1, -1:1))
        if n == (0, 0)
            continue
        end
        idx_new = idx + n
        if idx_new in axes(grid)
            count += grid[idx_new]
        end
    end
    return count
end


function update_grid_multiprocessing(grid)
    new_grid = copy(grid)
    @distributed for idx in CartesianIndices(grid)
        neighbors = count_neighbors(grid, idx)
        if grid[idx] == 1 && (neighbors < 2 || neighbors > 3)
            new_grid[idx] = 0
        elseif grid[idx] == 0 && neighbors == 3
            new_grid[idx] = 1
        else
            new_grid[idx] = grid[idx]
        end
    end
    return new_grid
end

@btime run_simul(update_grid_multiprocessing) # 1.299 ms (1663 allocations: 1.11 MiB)
