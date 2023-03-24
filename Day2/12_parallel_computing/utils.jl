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