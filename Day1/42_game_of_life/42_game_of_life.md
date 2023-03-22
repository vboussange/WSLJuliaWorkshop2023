# The game of life

The **Game of Life** is a classic cellular automaton invented by John Conway. In this simulation, each cell on a grid can either be alive or dead, and they change states according to a set of rules. The rules are as follows:

- Any live cell with two or three live neighbors survives.
- Any dead cell with three live neighbors becomes a live cell.
- All other live cells die in the next generation. Similarly, all other dead cells stay dead.

Here is a simulation of the Game of Life, with peculiar structures appearing and called gliders.

<div align="center"><img src="https://upload.wikimedia.org/wikipedia/commons/e/e5/Gospers_glider_gun.gif" width="400"></img> </div>

Cool huh!

Its evolution is determined by its initial state, requiring no further input. One interacts with the Game of Life by creating an initial configuration and observing how it evolves.

## Let's code that in Julia 🫵

- Define a function to count the number of live neighbors for each cell

```julia
function count_neighbors(grid, x, y)
    count = 0
    # some code
    return count
end

```

- Define a function to update the grid for one generation

```julia
function update_grid(grid)
    new_grid = copy(grid)
    for i in 1:size(grid, 1)
        for j in 1:size(grid, 2)
            # some code
        end
    end
    return new_grid
end
```

- Run the simulation for 50 generations. For this, initialize a random grid with size 
```julia
width = 50
height = 50
```
Print out the grid for each generation.

## Let's make things fancy!
Directly printing the array is not so nice. 
- Try to make it look like the gif above!
> Hint: you may use the `heatmap` function from Plots.jl, together with the `display` and the `sleep` function.

## Some other funny projects you can tackle

### Rock paper scissors

Try and code the following!

![](https://www.freecodecamp.org/news/content/images/2022/10/1-406j3f0e3nN-VxRJUUtK7A.gif)

Here is a possible solution

```julia
# Rock 🗿, Paper 📃, Scissors ✂️ Game in Julia

function play_rock_paper_scissors()
    moves = ["🗿", "📃", "✂️"]
    computer_move = moves[rand(1:3)]

    # Base.prompt is similar to readline which we used before
    human_move = Base.prompt("Please enter 🗿, 📃, or ✂️")
    # Appends a ": " to the end of the line by default

    print("Rock...")
    sleep(0.8)

    print("Paper...")
    sleep(0.8)

    print("Scissors...")
    sleep(0.8)
    
    print("Shoot!\n")

    if computer_move == human_move
        print("You tied, please try again")
    elseif computer_move == "🗿" && human_move == "✂️"
        print("You lose, the computer won with 🗿, please try again")
    elseif computer_move == "📃" && human_move == "🗿"
        print("You lose, the computer won with 📃, please try again")
    elseif computer_move == "✂️" && human_move == "📃"
        print("You lose, the computer won with ✂️, please try again")
    else
        print("You won, the computer lost with $computer_move, nice work!")
    end

end
```

## Resources
- [Learn Julia by Coding 7 Projects – Hands-On Programming Tutorial](https://www.freecodecamp.org/news/learn-julia-by-coding-7-projects/)
- ChatGPT...