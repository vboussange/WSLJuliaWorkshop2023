# Practical introduction to Julia-basics

We will cover:
- some more introduction
- docs
- variables
- datatypes
- arrays (longer exercise)
- flow control (small exercise)
- functions (larger exercise)
- multiple dispatch
- modules and packages

## Aside 1: Jupyter Notebooks

These slides are a [Jupyter notebook](https://jupyter.org/); a browser-based computational notebook.

Code cells are executed by putting the cursor into the cell and hitting `shift + enter`.  For more
info see the [documentation](https://jupyter-notebook.readthedocs.io/en/stable/).

## Aside 2: What is your previous programming experience?

1. Matlab/Octave
2. Python
3. R
4. other scripting languages (IDL, Mathematica, Perl...)
5. C, Fortran, ...
6. Pascal, Java, C++, ...
7. Lisp, Haskell, Assembler, Coq ...

(no prior programming experience?)

### What does Julia look like

Revisiting the Lorenz system of ODEs:

````julia
using OrdinaryDiffEq, Plots

function lorenz(x, p, t)
    σ = 10
    β = 8/3
    ρ = 28
    [σ*(x[2]-x[1]),
     x[1]*(ρ-x[3]) - x[2],
     x[1]*x[2] - β*x[3]]
end

# integrate dx/dt = lorenz(t,x) numerically from t=0 to t=50 and starting point x₀
tspan = (0.0, 50.0)
x₀ = [2.0, 0.0, 0.0]
sol = solve(ODEProblem(lorenz, x₀, tspan), Tsit5()); # the ; suppresses the output
````

Yes, this takes some time... Julia is Just-Ahead-of-Time compiled.  I.e. Julia is compiling.

And its solution plotted

````julia
plot(sol, idxs=(1,2,3)) # plot Lorenz attractor
````

###  Let's get our hands dirty!

Steps:
1) download this notebook & the `Project.toml` file (clone it, download them, etc.)
   - find in in `WSLJuliaWorkshop2023/Day1/13_julia-practical-on-jupyter/output/`
2) start Jupyter in the folder containing the two files:
   - at the command prompt `jupyter notebook`
   - in the Julia REPL `julia> using IJulia; notebook()`
3) open notebook `13_julia-practical-on-jupyter.ipynb` in browser

--> everyone got it running?

###  Let's get our hands dirty!

We will now look at
- using Jupyter notebooks
- querying and getting Julia documentation
- variables and types
- control flow
- functions
- modules and packages

###  Where are the docs?

The documentation of Julia is good and can be found at [https://docs.julialang.org](https://docs.julialang.org); although for learning it might be a bit terse...

There are also tutorials, see [https://julialang.org/learning/](https://julialang.org/learning/); in case we don't cover something

Help on functions, variables, etc. can be gotten with `?xyz` (execute it in a cell by itself)

````julia
# ?cos
````

###  DO: Get help on π (pi)

- what is it
- incidentally, how can you use unicode variables?

````julia
#
````

## Variables, assignments, and types
[https://docs.julialang.org/en/v1/manual/variables/](https://docs.julialang.org/en/v1/manual/variables/)

````julia
a = 4
b = "a string"
c = b # now b and c bind to the same value
````

Conventions:
- variables are (usually) lowercase, words can be separated by `_`
- function names are lowercase
- modules, packages and types are in CamelCase

### Variables: Unicode continued
From [https://docs.julialang.org/en/v1/manual/variables/](https://docs.julialang.org/en/v1/manual/variables/):

Unicode names (in UTF-8 encoding) are allowed:

```julia
julia> δ = 0.00001
1.0e-5

julia> 안녕하세요 = "Hello"
"Hello"
```

In the Julia REPL and several other Julia editing environments, you can type many Unicode math
symbols by typing the backslashed LaTeX symbol name followed by tab. For example, the variable
name `δ` can be entered by typing `\delta`-*tab*, or even `α̂⁽²⁾` by `\alpha`-*tab*-`\hat`-
*tab*-`\^(2)`-*tab*. (If you find a symbol somewhere, e.g. in someone else's code,
that you don't know how to type, the REPL help will tell you: just type `?` and
then paste the symbol.)

### Basic datatypes
- numbers (Ints, Floats, Complex, etc.)
- strings
- tuples
- arrays
- dictionaries

````julia
1     # 64 bit integer (or 32 bit if on a 32-bit OS)
1.5   # Float64
1//2  # Rational
````

````julia
typeof(1.5)
````

````julia
"a string", (1, 3.5) # and tuple
````

````julia
[1, 2, 3,] # array of eltype Int
````

````julia
Dict("a"=>1, "b"=>cos)
````

### Array exercises

We all use arrays extensively.

Datatypes belonging to AbstactArrays:
- `Array` (with aliases `Vector`, `Matrix`)
- `Range`
- GPU arrays, static arrays, Rasters (geo-data-arrays), etc

Task: assign two vectors to `a`, and `b` and the concatenate them using `;`:

````julia
a = [2, 3]
b = ...
[ ; ]
````

Add new elements to a empty Vector `c` (hint look up the documentation for `push!`)
((`push!` only works on Vectors, i.e. 1D arrays))

````julia
c = []
...
````

### Array exercises

Concatenate a Range, say `1:10`, with a Vector, say [4,5]:

````julia
[  ;  ]
````

Make a random array of size (3,3).  Look up `?rand`.  Assign it to `a`

````julia
#
````

### Array exercise: indexing

**Indexing starts at 1!**

Access element `[1,2]` and `[2,1]` of Matrix `a` (hint use []):

````julia
a[ ... ], a[ ... ]
````

Put those two values into a vector

````julia
#
````

Linear vs Cartesian indexing,
access the first element:

````julia
a[1]
a[1,1]
````

Access the last element (look up `?end`) both with linear and Cartesian indices

````julia
a[...]
a[..., ...]
````

### Array exercise: indexing by ranges

Access the last row of `a` (hint use `1:end`)

````julia
a[... , ...]
````

Access a 2x2 sub-matrix

````julia
a[ ]
````

### Array exercises: variable bindings and views

What do you make of

````julia
a = [1 4; 3 4] # note, this is another way to define a Matrix
c = a
a[1, 2] = 99
@assert c[1,2] == a[1,2]
````

Type your answer here (to start editing, double click into this cell.  When done shift+enter):

### Side-trip: macros

Macros, starting with `@`, work on the code itself and not the values as usual functions.

In general you don't need to care how they work, just use them.

Useful macros:

````julia
@assert 1==1 # checks that expression evaluates to true, otherwise errors

@time 1+1 # times how long the execution takes

@show a # prints the value of a.  Useful for simple debugging: put @show into your functions
````

### Array exercises: variable bindings and views

An assignment _binds_ the same array to both variables

````julia
c = a
c[1] = 8
@assert a[1]==8 # as c and a are the same thing
@assert a===c  # note the triple `=` meaning "identical"
````

Views vs copies:

In Julia indexing with ranges will create a new array with copies of
the original's entries (similar to Matlab, unlike Python). Consider

````julia
a = rand(3,4)
b = a[1:3, 1:2]
b[1] = 99
@assert a[1] != b[1]
````

### Array exercises: variable bindings and views

But the memory footprint will be large if we work with large arrays and take sub-arrays of them.

"Views" to the rescue (note: another macro)

````julia
a = rand(3,4)
b = @view a[1:3, 1:2]
b[1] = 99
````

check whether the change in `b` is reflected in `a`:

````julia
@assert ...
````

### Side-trip: types

All values have types as we saw above.  Arrays store in their type what type the elements can be.

> Arrays which have concrete element-types are more performant!

````julia
typeof([1, 2]), typeof([1.0, 2.0])
````

Aside, they also store their dimension in the second parameter.

The type can be specified at creation

````julia
String["one", "two"]
````

Create an array taking `Int` with no elements.  Push `1`, `1.0` and `1.5` to it.  What happens?

````julia
#
````

Make an array of type `Any` (which can store any value).  Push a value of type
Int and one of type String to it.

````julia
#
````

Try to assgin 1.5 to the first element of an array of type Array{Int,1}

````julia
#
````

### Array exercises

Create a uninitialised Matrix of size (3,3) and assign it to `a`.
First look up the docs of Array with `?Array`

````julia
#
````

Test that its size is correct, see `size`

````julia
#
````

### Array exercises: ALL DONE

The rest about Arrays you will learn-by-doing during the rest of the workshop.

## Control flow

Julia provides a variety of [control flow constructs](https://docs.julialang.org/en/v1/manual/control-flow/), of which we look at:

  * [Conditional Evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation): `if`-`elseif`-`else` and `?:` (ternary operator).
  * [Short-Circuit Evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#Short-Circuit-Evaluation): logical operators `&&` (“and”) and `||` (“or”), and also chained comparisons.
  * [Repeated Evaluation: Loops](https://docs.julialang.org/en/v1/manual/control-flow/#man-loops): `while` and `for`.
  * [Exception-Handling](https://docs.julialang.org/en/v1/manual/control-flow/#Exception-Handling): `throw`ing exception, `try`/`catch` blocks

### Conditional evaluation

Read the first paragraph of
[https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation)
(up to "... and no further condition expressions or blocks are evaluated.")

Write a test which looks at the start of the string in variable `a`
(?startswith) and sets `b` accordingly.  If the start is
- "Wh" then set `b = "Likely a question"`
- "The " then set `b = "A noun"`
- otherwise set `b = "no idea"`

````julia
#
````

### Conditional evaluation: the "ternary operator" `?`

Look up the docs for `?` (i.e. evaluate `??`)

Re-write using `?`
```
a = rand() * 10
if a > 5
    "really big"
else
    "not so big"
end
```

````julia
a = rand() * 10
...
````

### Short circuit operators `&&` and `||`

Read [https://docs.julialang.org/en/v1/manual/control-flow/#Short-Circuit-Evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#Short-Circuit-Evaluation)

Explain what this does

```
a < 0 && error("Not valid input for `a`")
```

Type your answer here (to start editing, double click into this cell.  When done shift+enter):

### Loops: `for` and `while`

[https://docs.julialang.org/en/v1/manual/control-flow/#man-loops](https://docs.julialang.org/en/v1/manual/control-flow/#man-loops)

````julia
for i = 1:3
    println(i)
end

for i in ["dog", "cat"] ## `in` and `=` are equivalent for writing loops
    println(i)
end

i = 1
while i<4
    println(i)
    global i += 1
end
````

## Functions

Functions can be defined in Julia in a number of ways.  In particular there is one variant
more suited to longer definitions, and one for one-liners:

```
function f(a, b)
   a * b
end
f(a, b) = a * b
```

Defining many, short functions is typical in good Julia code.

Read [https://docs.julialang.org/en/v1/manual/functions/](https://docs.julialang.org/en/v1/manual/functions/) up to an including "The return Keyword"

### Functions: exercises

Define a function in long-form which takes two arguments.
Use some if-else statements and the return keyword.

````julia
#
````

### Functions: exercises

Re-define the `map` function.  First look up what it does `?map`, then create a `mymap` which
does the same.  Map `sin` over the vector `1:10`.

(Note, this is a higher-order function: a function which take a function as a argument)

````julia
#
````

### Functions: dot-syntax

This is really similar to the `map` function, a short-hand to map/broadcast a
function over values.

Example:

````julia
sin.(1:10)
````

--> more about this in the afternoon

### Functions: anonymous functions

So far our function got a name with the definition. They can also be defined without name.

Read [https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions)

Map the function `f(x,y) = sin(x) + cos(x)` over `1:10` but define `f` as an anonymous
function.

````julia
map(..., 1:10)
````

### Key feature: multiple dispatch functions

- Julia is not an object oriented language

OO:
- methods belong to objects
- method is selected based on first argument (e.g. `self` in Python)

Multiple dispatch:
- methods are separate from objects
- are selected based on all arguments
- similar to overloading but method selection occurs at runtime and not compile-time (see also video below)
> very natural for mathematical programming

JuliaCon 2019 presentation on the subject by Stefan Karpinski
(co-creator of Julia):

["The Unreasonable Effectiveness of Multiple Dispatch"](https://www.youtube.com/watch?v=kc9HwsxE1OY)

## Functions: Multiple dispatch demo

````julia
struct Rock end
struct Paper end
struct Scissors end
### of course structs could have fields as well
# struct Rock
#     color
#     name::String
#     density::Float64
# end

# define multi-method
play(::Rock, ::Paper) = "Paper wins"
play(::Rock, ::Scissors) = "Rock wins"
play(::Scissors, ::Paper) = "Scissors wins"
play(a, b) = play(b, a) # commutative

play(Scissors(), Rock())
````

### Multiple dispatch demo
Can easily be extended later

with new type:

````julia
struct Pond end
play(::Rock, ::Pond) = "Pond wins"
play(::Paper, ::Pond) = "Paper wins"
play(::Scissors, ::Pond) = "Pond wins"

play(Scissors(), Pond())
````

with new function:

````julia
combine(::Rock, ::Paper) = "Paperweight"
combine(::Paper, ::Scissors) = "Two pieces of papers"
# ...

combine(Rock(), Paper())
````

*Multiple dispatch makes Julia packages very composable!*

This is a key characteristic of the Julia package ecosystem.

## Modules and packages

Modules can be used to structure code into larger entities, and be used to divide it into
different name spaces.  We will not make much use of those, but if interested see
[https://docs.julialang.org/en/v1/manual/modules/](https://docs.julialang.org/en/v1/manual/modules/)

**Packages** are the way people distribute code and we'll make use of them extensively.
In the first example, the Lorenz ODE, you saw
```
using OrdinaryDiffEq, Plots
```
This statement loads the two packages `OrdinaryDiffEq` and `Plots` and makes their functions
and types available in the current session.

````julia
using Plots
plot( (1:10).^2 )
````

### Packages

Packages are in a sense Modules which you can install and then use.

All public Julia packages are listed on [https://juliahub.com/ui/Packages](https://juliahub.com/ui/Packages).

You can install a package, say `UnPack.jl` by
```
using Pkg
Pkg.add("UnPack.jl")
using UnPack
```

In the REPL, there is also a package-mode (hit `]`) which is for interactive use.

--> more about this later in the workshop

## This concludes the rapid Julia tour

There are many more features of Julia for sure but this should get you started for
the workshop.

Remember you can self-help with:
- using `?` at the notebook or REPL.  Similarly there is an `apropos` function.
- the docs are your friend [https://docs.julialang.org/en/v1/](https://docs.julialang.org/en/v1/)
- ask us for help!

