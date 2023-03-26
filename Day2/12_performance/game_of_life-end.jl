using BenchmarkTools

@inline function count_neighbours(ar, i, j)
    n = 0
    @inbounds for jj = j-1:j+1
        for ii = i-1:i+1
            ii==i && jj==j && continue
            if ar[ii,jj]
                n += 1
            end
        end
    end
    return n
end

# 1) Any live cell with two or three live neighbors survives.
# 2) Any dead cell with three live neighbors becomes a live cell.
# 3) All other live cells die in the next generation.
# 4) Similarly, all other dead cells stay dead.
function update_grid!(grid, workarray)
    workarray .= grid
    @inbounds for j = 2:size(grid,2)-1
        for i = 2:size(grid,1)-1
            n = count_neighbours(workarray, i,j)
            alive = workarray[i,j]
            if alive
                if n<2 || n>3
                    grid[i,j] = false
                end
            else
                if n==3
                    grid[i,j] = true
                end
            end
        end
    end
    return grid
end


h, v = 80,80
grid = rand(Bool, h, v)

glider = Bool[0 1 0
              0 0 1
              1 1 1]

glider_grid = zeros(Bool, h, v)
glider_grid[end÷2:end÷2 + 2, end÷2:end÷2 + 2] .= glider

grid = copy(glider_grid)

# set boundary ghost-cells to 1
grid[1,:] .= grid[end,:] .= 0
grid[:,1] .= grid[:,end] .= 0

# using Plots
# for i = 1:50
#     update_grid!(grid)
#     display(heatmap(grid))
#     sleep(0.001)
# end

@btime count_neighbours($grid, 5, 8)
work = copy(grid)
@btime update_grid!($grid, $work)
