#src # This is needed to make this run as normal Julia file:
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Plotting in Julia

As so often in open source, there is not just one package but many.

Probably the most prolific are:
- [Plots.jl](https://github.com/JuliaPlots/Plots.jl) which itself wraps many underlying plotting packages.
- [PythonPlot.jl](https://github.com/stevengj/PythonPlot.jl) interface to the well known `matplotlib` Python plotting package
  (formerly `PyPlot.jl`)
- [Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl) a grammar of graphics based plotting (similar to R, I think)
- [Makie.jl](https://github.com/MakieOrg/Makie.jl) a pure Julia, high-performance plotting package.  Cool, but slow to load.
- many more: UnicodePlots.jl, PlotlyJS.jl, PGFPlotsX.jl, GMT.jl, Gnuplot.jl, VegaLite.jl, etc.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
**I will show-case Plots.jl**

Follows [https://docs.juliaplots.org/latest/tutorial/](https://docs.juliaplots.org/latest/tutorial/)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Plots.jl

Pros:
- probably most widely used plotting package
- many packages provide out-of-the box functionality with Plots.jl
- can use different backends

Cons:
- medium-slow to load
- fine-scale tweaks can be hard to do or find out how to do

Alternatively, I sometimes use `PythonPlot.jl`
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Install Plots.jl

Install Plots:
"""

using Pkg
Pkg.add("Plots")
# the GR.jl backend comes automatically installed

md"""
Install [backends](https://docs.juliaplots.org/latest/backends/) if needed/wanted:
"""

## this may install a whole Conda-Python install, depending on whether
## it can find python and matplotlib or not
## Pkg.add("PythonPlot")

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Basic usage

Plot a line plot
"""
using Plots
x = range(0, 10, length=100)
y = sin.(x)
plot(x, y)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Basic usage

Plot another line plot, note the **!**
"""
y = cos.(x)
plot!(x, y)


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Basic usage

Save it as a file
"""
savefig("test.png")

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Refining plots: attributes

All attributes are listed [here](https://docs.juliaplots.org/latest/attributes/#attributes)
"""
x = range(0, 10, length=100)
y = sin.(x)
plot(x, y, label="sin", linewidth=2)
c = cos.(x)
plot!(x, c, label="cos", marker = :hexagon)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Refining plots: type of plots

scatter, heatmap, etc

See [gallery](https://docs.juliaplots.org/latest/gallery/pythonplot/)
"""

heatmap(rand(80,90))

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Subplots

[https://docs.juliaplots.org/latest/layouts/](https://docs.juliaplots.org/latest/layouts/)
"""

plot(plot(x, sin.(x)),
     plot(x, cos.(x)),
     heatmap(rand(40,56)),
     layout=(3,1)
     )

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Subplots

[https://docs.juliaplots.org/latest/layouts/](https://docs.juliaplots.org/latest/layouts/)
"""

p1 = plot(x, sin.(x))
p2 = plot(x, cos.(x))
p3 = heatmap(rand(40,56))
plot(p1, p2, p3, layout=(3,1) )

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Plots.jl recipes

Many Julia packages provide so-called recipes to plot using Plots.jl

Example with [Measurements.jl](https://juliaphysics.github.io/Measurements.jl/stable/examples/#Integration-with-Plots.jl) plotting error-bars automatically
"""
Pkg.add("Measurements")
using Measurements
x = [x ± 0.1 for x in 1:0.2:10] # these numbers now have an uncertainty of +/- 0.1
plot(x, sin.(x), size = (1200, 800))


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Plots.jl backends

Plots.jl is a wrapper around other plotting libraries, so-called backends.
Different backends have different abilities, say zoom-able vs not.

Default is GR.jl (fast but not interactive)
"""
Pkg.add("PythonPlot")
pythonplot()
## re-plot previous plot
plot(x, sin.(x), size = (1200, 800),
     ticks=:native) # this can be useful, as only then ticks get re-rendered on zoom
