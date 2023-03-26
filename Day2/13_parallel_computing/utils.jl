# Define a function to update the plot for one generation
function update_plot(grid)
    grid = update_grid(grid)
    p = heatmap(grid, 
                c=:Greys, 
                legend = :none, 
                xaxis=false, 
                yaxis=false, 
                ticks=false)
    return grid, p
end

# Define a function to count the number of live neighbors for each cell
function count_neighbors(grid, idx)
    count = 0
    for n in CartesianIndices((-1:1, -1:1))
        if n == (0, 0)
            continue
        end
        idx_new = idx + n
        if (0 < idx_new[1] <= size(grid,1)) && (0 < idx_new[2] <= size(grid,2))
            count += grid[idx_new]
        end
    end
    return count
end