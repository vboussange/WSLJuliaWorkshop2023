function count_neighbours(ar, I)
    R = CartesianIndices(ar)
    I1, Iend = first(R), last(R)

    n = 0
    for J in max(I1, I-I1):min(Iend, I+I1)
        I==J && continue
        if ar[J]==true
            n += 1
        end
    end
    return n
end


# test it
for i=1:10000
    ar = rand(Bool, 3,3)
    ar[2,2] = 0
    @assert count_neighbours(ar, CartesianIndex(2,2)) == sum(ar)

    ar = rand(Bool, 3,3)
    ar[3,1:end] .= false
    ar[1:end,3] .= false
    ar[1,1] = false
    @assert count_neighbours(ar, CartesianIndex(1,1)) == sum(ar)
end

# 1) Any live cell with two or three live neighbors survives.
# 2) Any dead cell with three live neighbors becomes a live cell.
# 3) All other live cells die in the next generation.
# 4) Similarly, all other dead cells stay dead.

function update_grid!(grid)
    old_grid = copy(grid)
    for I in CartesianIndices(grid)
        n = count_neighbours(old_grid, I)
        alive = old_grid[I]
        if alive
            if n<2 || n>3
                grid[I] = false
            end
        else
            if n==3
                grid[I] = true
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

using Plots
for i = 1:100
    update_grid!(grid)
    display(heatmap(grid))
end
