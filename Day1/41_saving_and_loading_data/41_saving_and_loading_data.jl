#src # This is needed to make this run as normal Julia file:
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Storing and loading data in Julia
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Many ways, again:
- `DelimitedFiles` -- built in for reading delimited text data (csv-files) into an array
  - `CSV.jl` is more performant and makes a data-frame
- any Julia thing:
  - [JLD2.jl](https://github.com/JuliaIO/JLD2.jl)
  - [BSON.jl](https://github.com/JuliaIO/BSON.jl)
  - [JLSO.jl](https://github.com/invenia/JLSO.jl) <-- will show this
- specialized data
  - HDF5
  - [NetCDF.jl](https://github.com/JuliaGeo/NetCDF.jl)
  - geo-data via Rasters.jl (on Monday
  - images, feather, ...
  - etc
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# House keeping
"""
using Pkg
Pkg.instantiate()

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# DelimitedFiles

This is a standard library, i.e. ships with Julia, i.e. no need to install.
"""

using DelimitedFiles
data = rand(4,5)

## ?DelimitedFiles.writedlm
##
## writedlm(f, A, delim='\t'; opts)

writedlm("test.csv", data, ',')
data2 = readdlm("test.csv", ',')
data==data2

## can do header, etc. too



#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Store anything (almost)

To store anything, I mostly use JLSO.jl, but JLD2.jl should work too

"""
using JLSO

data1 = Dict(:a => "A", :b => sin)
JLSO.save("test.jlso", data1)

out = JLSO.load("test.jlso")
