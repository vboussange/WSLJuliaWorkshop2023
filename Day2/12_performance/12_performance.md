# Performance tuning in Julia

Slow code can be written in any language

## Julia concepts

- put your code performance critical code into a function

- type stability (`@code_warntype` is your friend)

- only use `const` globals in performance critical code

- benchmark your code: use `@time` (run twice to compile it) or better
  `@btime` from BenchmarkTools.jl

- profile your code:
  - https://docs.julialang.org/en/v1/manual/profile/#Profiling
  - https://github.com/timholy/ProfileView.jl

- before starting performance tuning, it's good to setup tests to make
  sure your code outputs the same

## BenchmarkTools.jl

Use the `$` trick with the `@btime` macro:

```julia
a = rand(5)
@btime sin.($a)
```

## Julia resources

- First and foremost: [Performance Tips in the Julia documentation](https://docs.julialang.org/en/v1/manual/performance-tips/)

- Dirty trick: go on [Julia Discourse](https://discourse.julialang.org/) and state that you
ported code from Matlab/Python/R to Julia and it's now slower... (do
use resources of other people very sparingly!)

## Exercise

Take your Game of Life code and improve its performance.

If you did not code a solution, take the one
[here](../../Day1/42_game_of_life/42_game_of_life_solution.md)
