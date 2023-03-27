using Literate

Literate.notebook("11_geodata.jl",
                  credit=false, execute=false, mdstrings=true)

Literate.markdown("11_geodata.jl",
                  credit=false, execute=false, mdstrings=true, flavor=Literate.CommonMarkFlavor())

Literate.notebook("11_geodata-ex.jl",
                  credit=false, execute=false, mdstrings=true)

Literate.markdown("11_geodata-ex.jl",
                  credit=false, execute=true, mdstrings=true, flavor=Literate.CommonMarkFlavor())
