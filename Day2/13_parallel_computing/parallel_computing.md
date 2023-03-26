# Parallel and Distributed Computing

**Multithreading** refers to the ability of a processor to execute multiple threads concurrently, where each thread runs a process. **Multiprocessing** refers to the ability of a system to run multiple processors concurrently, where each processor can run one or more threads.

![](https://miro.medium.com/v2/resize:fit:720/format:webp/1*hZ3guTdmDMXevFiT5Z3VrA.png)

## Multithreading
Multi-threading is a programming technique that allows **multiple threads** of execution to run concurrently within a single process. Julia provides built-in support for multi-threading, making it easy to write concurrent code. To use multi-threading in Julia, you can use the Threads standard library.

The number of execution threads is controlled either by using the `-t`/`--threads` command line argument 

```shell
julia --threads 10 my_script.jl
```

or by using the `JULIA_NUM_THREADS` environment variable. This can also be changed in VSCode setting. 

When both `JULIA_NUM_THREADS` and `-t`/`--threads` are specified, then `-t`/`--threads` takes precedence.

The number of threads can either be specified as an integer (`--threads=4`) or as auto (`--threads=auto`), where auto sets the number of threads to the number of local CPU threads.

```julia
Threads.nthreads()
```

Multithreading in Julia is **super easy**: just put `Threads.@threads` in front of the loop you want to parrallelize.
```julia
a = zeros(10)
Threads.@threads for i = 1:10
    a[i] = Threads.threadid()
end
```

### Be careful with race condition!

```julia
a = []
Threads.@threads for i in 1:1000
    x = i^2
    push!(a, x)
end
println(length(a)) # !== 1000
```
#### `lock`

The `lock` function can be used to prevent race condition
```julia
a = []
lk = ReentrantLock()
Threads.@threads for i in 1:1000
    x = i^2
    lock(lk) do
        push!(a, x)
    end
end
println(length(a)) # ==1000
```

### 👍 How I use multithreading in my simulations

I typically have an expensive function that I want to call multiple times with different arguments.

```julia
function simul(noise, batch_size)
   # do something with noise and batch_size
   println("running simulation for noise = ", noise, ", batch_size = ", batch_size)
    sleep(1)
    return randn()
end
```

`simul` does some simulation based on these parameters, then returns the simulation result.

I want to loops through all combinations of the arguments proposed. Let's do so by creating a dictionary `pars` for each combination of arguments, and adding it to an array `pars_arr`.


```julia
# initialising df and pars
pars_arr = Dict[]

noises = [0.1, 0.2, 0.3]
batch_sizes = [1000, 2000, 3000]

for noise in noises, batch_size in batch_sizes
    pars = Dict()
    pars["noise"] = noise
    pars["batch_size"] = batch_size
    push!(pars_arr, pars)
end
```

We'll also create a `DataFrame` to store the results.

```julia
using DataFrames
df_results = DataFrame("Result" => [],
                    "noise" => [],
                    "batch_size" => [])
```

Here is how I would run the simulations.

```julia
using ProgressMeter
progr = Progress(length(pars_arr), showspeed = true, barlen = 10)

loc = Threads.ReentrantLock()

Threads.@threads for k in 1:length(pars_arr)
    p = pars_arr[k]
    noise = p["noise"]
    batch_size = p["batch_size"]
    try
        out = simul(noise, batch_size)
        lock(loc) do
            push!(df_results, (out, noise, batch_size));
        end
    catch e
        println("problem with p = $(pars_arr[k])")
        println(e)
    end
    next!(progr)
end
```

I like using `ProgressMeter`, to get a sense of where my computation is at.

### Atomic operations
Note that you can also perform something called atomic operations, see the [dedicated section](https://docs.julialang.org/en/v1/manual/multi-threading/#Atomic-Operations) in Julia documentation. Atomic operations are similar to what you could do with `lock`, although they may be faster but more limited in what you could do.
## Multi-processing

Julia has also a built-in library for distributed parallel computing, called `Distributed`. Although it is generally more difficult to deploy than mulitthreading, it may be useful in certain occasions.  Distributed computing is useful when you have a lot of work that cannot be split among multiple threads and needs to be distributed across multiple machines.

A simple example where distributed computing may be more appropriate than multithreading is in the case of a data-intensive application that needs to process a large dataset. Let's say we have a dataset with 1 billion rows, and we want to perform a calculation on each row of the dataset. If we try to process this dataset using multithreading, we may run into memory limitations, as all the threads will be running within the same process and using the same memory space. This could result in slow performance and even crashes.

Monte Carlo simulations is another good use-case with distributed computing may be useful.


`julia -p 4` provides `4` worker processes on the local machine. Alternatively, within Julia you can add workers by 
```julia
using Distributed
addprocs(4)  # add 4 worker processes
```

The most straightforward way of performing distributed computing is using
### `pmap`

```julia
function species_richnesss(data::Array{Int, 2})
    n_plots, n_species = size(data)
    result = zeros(n_plots)

    for i = 1:n_plots
        result[i] = length(unique(data[i, :]))
    end

    return result
end

data = [rand(1:10, 1000, 100) for i in 1:10]  # generate random data
result = pmap(species_richnesss, data)  # calculate species richness using 4 worker processes
```

Julia's pmap is designed for the case where each function call does a large amount of work. In contrast, @distributed for can handle situations where each iteration is tiny, perhaps merely summing two numbers. Only worker processes are used by both pmap and @distributed for for the parallel computation. I

The use of `@everywhere` is required so that every process has access to the function `species_richness`

#### `MPI.jl`
There exists an MPI (Message Passing Interface) interface for the Julia language, provided by the `MPI.jl` package. MPI is a low-level communication protocol that enables message passing between processes running on different nodes in a distributed system. It may be a better choice due to its interoperability, customization options, performance, and scalability on large-scale systems. If you never heard of it, then forget about it!


## GPU computing

Multiple dispatch allows your code to be executed on GPUS! Here is how.

Assume
```julia

function myfun(a::AbstractArray, b::AbstractArray)
    return sum(a.^2 .* b)
end

# generate CPU arrays
a = rand(Float32, 1000, 1000)
b = rand(Float32, 1000, 1000)

using BenchmarkTools
@btime myfun(a, b) # 820.959 μs (3 allocations: 7.63 MiB)
```

### GPU programming on MacOS
```julia
using Metal
a_gpu = MtlArray(a)
b_gpu = MtlArray(b)

@btime myfun(a_gpu, b_gpu)
```

### GPU programming with CUDA
```julia
using CUDA

if CUDA.functional()
    a = CUDA.rand(1000, 1000)
    b = CUDA.rand(1000, 1000)
    @btime myfun(a, b)
end

```

### Additional resources
- [Discourse category Julia at scale](https://discourse.julialang.org/c/domain/parallel/34)
- [Further explanations on Multithreading vs Multiprocessing computing](https://towardsdatascience.com/multithreading-and-multiprocessing-in-10-minutes-20d9b3c6a867)
- [Julia multi threading](https://docs.julialang.org/en/v1/manual/multi-threading/)
