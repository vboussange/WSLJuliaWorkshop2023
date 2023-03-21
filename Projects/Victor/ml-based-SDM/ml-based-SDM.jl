cd(@__DIR__)
using DataFrames, CSV, Rasters
using RCall
using Plots

bird_occurrences = DataFrame(CSV.File("data/bird_presence.csv"))
species_names = names(bird_occurrences[:, Not([:x, :y, :KoordID])])
env_var = Raster("data/bird_extent_stack.nc")

pnts = collect([r.x, r.y] for r in eachrow(bird_occurrences))
collect(extract(env_var, pnts, dims=(1,2)))

env_var_bird = extract(env_var, Array(bird_occurrences[:, [:x, :y]]))
env_var_names = names(env_var_bird)
bird_data = hcat(bird_occurrences, env_var_bird)
bird_data = bird_data[:, [species_names..., env_var_names...]]
bird_data = dropmissing(bird_data)