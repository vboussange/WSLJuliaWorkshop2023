# Parallel and Distributed Computing

## Multithreading
Multi-threading is a programming technique that allows multiple threads of execution to run concurrently within a single process. Julia provides built-in support for multi-threading, making it easy to write concurrent code. To use multi-threading in Julia, you can use the Threads standard library.

The number of execution threads is controlled either by using the -t/--threads command line argument or by using the JULIA_NUM_THREADS environment variable. When both are specified, then -t/--threads takes precedence.

The number of threads can either be specified as an integer (--threads=4) or as auto (--threads=auto), where auto sets the number of threads to the number of local CPU threads.

```julia
Threads.nthreads()
```

You can also modify the number of threads within the Julia extension of VS Code

Multithreading in Julia is **super easy**: just put `Threads.@threads` in front of the loop you want to parrallelize.
```julia
a = zeros(10)
Threads.@threads for i = 1:10
    a[i] = Threads.threadid()
end
```

Be careful with race condition!
```julia
acc = Ref(0)
Threads.@threads for i in 1:1000
    acc[] += 1
end
println(acc[])
```

### How I use multithreading in my simulations

I usually have a resource heavy function that I want to call multiple times with different arguments.

```julia
function simul(p)
   # do something with p...
    @unpack noise = p
    sleep(1)
    res = randn()
    return res
end
```

Let's assume that we want to run `simul` with different level of noises.

We'll create an array of parameters, and a dataframe to store the results

```julia
# initialising df and pars
pars_arr = Dict{String,Any}[]

df_results = DataFrame( "Result" => [],
                        "noise" => [])

p_trained, _ = destructure(p_true)
inf_res = InferenceResult(;model, p_trained = p_trained)
for noise in noises
        pars = Dict{String,Any}()
        @pack! pars = noise
        push!(pars_arr, pars)
        push!(df_results, (inf_res = inf_res,
                            noise))
end
```

Let's run the simulation. I like using `ProgressMeter`, to get a sense of where my computation is at.

```julia
using ProgressMeter
progr = Progress(length(pars_arr), showspeed = true, barlen = 10)
Threads.@threads for k in 1:length(pars_arr)
    try
        df_results[k,:] = (simu(pars_arr[k])..., true);
    catch e
        println("problem with p = $(pars_arr[k])")
        println(e)
    end
    next!(progr)
end
```

## Multi-processing


Multi-threading is a programming technique that allows multiple threads of execution to run concurrently within a single process. Julia provides built-in support for multi-threading, making it easy to write concurrent code. To use multi-threading in Julia, you can use the Threads standard library.

Here's an example of using multi-threading to speed up a calculation of the mean temperature of a glacier using data from multiple weather stations:

```julia
using Distributed

addprocs(4)  # add 4 worker processes

@everywhere function species_richness(data::Array{Int, 2})
    n_plots, n_species = size(data)
    result = zeros(n_plots)

    for i = 1:n_plots
        result[i] = length(unique(data[i, :]))
    end

    return result
end

data = rand(1:10, 1000, 100)  # generate random data
result = pmap(species_richness, data)  # calculate species richness using 4 worker processes

```
This function calculates the mean temperature for each day using multiple threads to process each day's data simultaneously. By using multi-threading, we can significantly speed up the calculation, especially for large datasets.

## Distributed Computing
