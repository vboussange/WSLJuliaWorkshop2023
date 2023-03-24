#src # This is needed to make this run as normal Julia file:
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# The Julia Ecosystem

I will look at:
- the package ecosystem
- the community
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# The Package Ecosystem

- Packages can be easily installed, into project environments (as explained by Victor before) if desired.
- Registered packages are listed on [https://juliahub.com/ui/Packages](https://juliahub.com/ui/Packages)
- google / duckduckgo / bing / etc search often works well.  Appending `jl` often helps.
- the package ecosystem has not reached the level of the Python ecosystem but is growing fast.  There are currently 9141 registered packages.

--> packages work well together, e.g. combine [OrdinaryDiffEq.jl](https://github.com/SciML/OrdinaryDiffEq.jl) with [Unitful.jl](https://github.com/PainterQubits/Unitful.jl) and [Measurements.jl](https://github.com/JuliaPhysics/Measurements.jl)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Package interoperability

Example from [DiffEq docs](https://docs.sciml.ai/SciMLTutorialsOutput/html/type_handling/03-unitful.html), combining a package for units with a differential equation solver:
"""
using Unitful
t = 1.0u"s" # has units seconds
t + 1.0u"s" # works, adding kg would error

#-
using OrdinaryDiffEq
## dy / dt  = f(x, p, t)
f = (y,_,t) -> 0.5*y/3.0u"s"
u0 = 1.5u"N"
prob = ODEProblem(f,u0,(0.0u"s",1.0u"s"))
sol = solve(prob,Tsit5())


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Package interoperability

Let's plot the solution:
"""
using Plots
plot(sol.t, sol[:])


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### There are many **cutting-edge** packages

- [DifferentialEquations.jl](https://github.com/JuliaDiffEq/DifferentialEquations.jl), probably the best differential equation solver package around
- [Flux.jl](https://fluxml.ai/2019/02/07/what-is-differentiable-programming.html) machine learning/differentiable programming package (Victor will have a project using that on Monday)
- [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl) mathematical optimisation package, big in, e.g., operations research
- automatic differentiation (AD): [Enzyme.jl](https://github.com/EnzymeAD/Enzyme.jl), [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl), many [others](https://juliadiff.org/#the_big_list)

--> above packages can work together to allow, e.g., *Scientific machine learning*, combining differential equation-based, physical models with machine learning: [link to blog](https://fluxml.ai/blog/2019/03/05/dp-vs-rl.html)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### My favorite packages

Utilities:
- BenchmarkTools.jl and ProfileView.jl for performance tweaking
- IJulia.jl (Jupyter notebooks)
- Literate.jl produces notebooks and markdown from scripts (as I don't like notebooks after all...)
  - -> used for the slides and exercises in this workshop
- Infiltrator.jl a debugger: not the prettiest but works ok and does not impact performance
- Plots.jl basic plotting
- Revise.jl makes code updates in packages visible immediately to the current running Julia process

*Install for sure into global environment: Revise.jl and BenchmarkTools.jl*
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### My favorite packages

- Rasters.jl for raster geo-data
- JLSO.jl for storing anything
- OrdinaryDiffEq.jl to solve Ordinary Differential Equations (ODEs)

A few HPC (Ludovic's favorits):
- MPI.jl -- inter-node communication on clusters
- CUDA.jl, AMDGPU.jl -- to run Julia code on Nvidia and AMD GPUs
- ParallelStencil.jl, ImplicitGlobalGrid.jl -- packages he's developing to solve PDEs on GPUs
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Our packages

Victor:
- HighDimPDE.jl -- to solve high dimensional PDEs
- EvoId.jl -- Evolutionary Individual based modelling, mathematically grounded.
- PiecewiseInference.jl -- Suite for parameter inference and model selection with dynamical models characterised by complex dynamics.
- EcoEvoModelZoo.jl -- A zoo of eco-evolutionary models with high fitness.

Mauro:
- Parameters.jl, UnPack.jl and SimpleTraits.jl -- utility packages (slowly getting superseded by Julia language features)
- KissMCMC.jl -- an affine invariant MCMC sampler
- WhereTheWaterFlows.jl -- a flow routing package, uses the D8 algorithm

"""



########################################## #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Julia Community

The Julia community is very friendly and helpful:

- Easy to get help on
  - [discourse forum](https://discourse.julialang.org)
  - StackOverflow (ok, maybe there it's less easy)
  - and on more informal chat-clients: [Slack](https://julialang.slack.com/), [Zulip](https://julialang.zulipchat.com/register/)
- Active developer community on GitHub
- The yearly [JuliaCon](https://juliacon.org) is as fun and friendly conference (next one in July at MIT and online)
"""
