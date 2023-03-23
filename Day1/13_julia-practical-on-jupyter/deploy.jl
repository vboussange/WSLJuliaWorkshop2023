using GlacioTeaching

fl = "13_julia-practical-on-jupyter.jl"
for typ in [:jl, :md, :nb]
    GlacioTeaching.process_file(fl, "output", typ;
                                make_outputs=[:sol, :assignment, :no_preprocessing][2],
                                execute=[:sol, true, false][1],
                                sub_nbinclude=true,
                                path_nbinclude=nothing,
                                keep_comments=true)

    GlacioTeaching.process_file(fl, "output-sol", typ;
                                make_outputs=[:sol, :assignment, :no_preprocessing][1],
                                execute=[:sol, true, false][1],
                                sub_nbinclude=true,
                                path_nbinclude=nothing,
                                keep_comments=true)
end
cp("Project.toml", "output/Project.toml")
cp("Project.toml", "output-sol/Project.toml")
