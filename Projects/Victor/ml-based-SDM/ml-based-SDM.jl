using DataFrames, CSV, RData, Rasters

bird_occurrences = DataFrame(CSV.File("data/bird_presence.csv"))
species_names = names(bird_occurrences[:, Not([:x, :y, :KoordID])])
env_var = load("data/bird_extent_stack.rds")["values"]
env_var_bird = extract(env_var, bird_occurrences[!, [:x, :y]])
env_var_names = names(env_var_bird)
bird_data = hcat(bird_occurrences, env_var_bird)
bird_data = bird_data[:, [species_names..., env_var_names...]]
bird_data = dropmissing(bird_data)