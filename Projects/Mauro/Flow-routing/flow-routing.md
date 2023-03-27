# Hydrological flow routing using flow accumulation (D8)

Flow accumulation routing is very simple.  In this project you will
use the
[WhereTheWaterFlows.jl](https://github.com/mauro3/WhereTheWaterFlows.jl)
code to route water over digital elevation models (DEMs).

## Setup a project

Think about whether you want to use Jupyter notebooks or just scripts.

Setup a Julia environment in your project folder.


## Load Swiss DEM

Use the code from the geo-data session (Day 2) to load the Swiss DHM
data.

## Use WhereTheWaterFlows.jl

Have a look at the code.

- route the water on the Swiss DEM.
- calculate the catchments upstream of Geneve, Basel and Zurich.  Be
  careful to catch the main flow path.
- find some mean, distributed precipitation data and try to estimate
  the discharge expected at those locations

## Large-scale run

Try downloading the high-res Swiss DEM and run WhereTheWaterFlows.jl

If you run into stack-overflows, consider fixing
https://github.com/mauro3/WhereTheWaterFlows.jl/issues/13
