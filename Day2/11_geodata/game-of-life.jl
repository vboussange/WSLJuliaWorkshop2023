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
