using Weave

# Set the input and output filenames
path_to_file = "/Users/victorboussange/ETHZ/PostDoc_ELE/teaching/WSL_workshop_Julia/material/Day1/32_dataframe_tuto/"
namefile = "33_dataframe_exercises"

input_file = joinpath(path_to_file, namefile*"_with_sols.jmd")

set_chunk_defaults!(:echo => false);
set_chunk_defaults!(:results => :hidden);
set_chunk_defaults!(:eval => false);

weave(input_file; doctype="github")

# renaming the markdown without solutions
run(```mv $(joinpath(path_to_file, namefile*"_with_sols.md")) $(joinpath(path_to_file, namefile*".md"))```)
# rm(temp_dir, recursive=true)