using Literate

Literate.notebook("33_plotting.jl",
                  credit=false, execute=true, mdstrings=true)

Literate.markdown("33_plotting.jl",
                  credit=false, execute=true, mdstrings=true, flavor=Literate.CommonMarkFlavor())
