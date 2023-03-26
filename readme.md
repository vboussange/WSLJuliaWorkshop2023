# Practical introduction to Julia for modelling and data analysis in biodiversity and earth sciences

This repository contains materials for the [WSL Julia Workshop 2023](https://www.wsl.ch/de/ueber-die-wsl/die-wsl-im-dialog/details/practical-introduction-to-julia-for-modelling-and-data-analysis-in-biodiversity-and-earth-sciences.html) **Practical introduction to Julia for modelling and data analysis in biodiversity and earth sciences**, held on the 24th and 27th of March 2023 at WSL Birmensdorf.

# Content

The repository is organized by days and sessions. Please refer to the [Program](#program) section to navigate within the repo.

# Requirements

To follow the workshop materials, you need to have the following software installed on your computer:
- Julia
- Jupyter

Additionally, we recommend to use
- VSCode

as an IDE, together with the Julia extension.

Please refer to the [installation instructions](Misc/installation_instructions.md) for further information on how to proceed.


# Usage

To use the workshop materials, clone this repository to your local machine:

```sh
git clone https://github.com/vboussange/WSLJuliaWorkshop2023.git
```

# Program
How you should read this program
- 🎤 : Talk
- 💻: Hands-on exercises
- 🎤💻: Interactive session
## Day 1: Introduction to the Language, hands on exercises

**8:50** Arrival at Englersaal, WSL (ask at the reception if you don't
know where that is)

### Morning session 1
**9:00 - 10:30**

- 🎤 Greetings to the Workshop (@Mauro and @Victor) **9:00-9:10**
- 🎤 Overview of the Julia programming language (@Mauro) **9:10-9:30**
- 🎤💻 [**Practical**: your first lines of Julia code](Day1/13_julia-practical-on-jupyter/output) (@Mauro) **9:30-10:30**
  - **Practical** Basic syntax and data types
  - **Practical** Control flow and conditional statements
> Pick up any format you like best among the `.ipynb`, `.md` and `.jl` files. Their content is the same!

### Coffee break
**10:30 - 11:00**

### Morning session 2
**11-12:30**
- 🎤 [Why I like Julia](Day1/21_why-i-like-julia-VB/21_why-i-like-julia-VB.ipynb) (@Victor) **11:00-11:15**

- Package and project management (@Victor) **11:15-11:45**
  - 💻🎤 [Introduction to `Pkg.jl`](Day1/22_pkg_and_project_management/Pkg.ipynb)
  - 💻[Exercise 1: activate an environment and run the associated script](Day1/22_pkg_and_project_management/exercise1.md)
  - 💻[Exercise 2: Part 1](Day1/22_pkg_and_project_management/exercise2.md): Set-up the environment of your project

  - 💻🎤[Julia projects managements](Day1/22_pkg_and_project_management/practical_guideline.ipynb)
  - 💻[Exercise 2: Part 2.](Day1/22_pkg_and_project_management/exercise2.md) Develop your first Julia project


- 💻🎤 [VS code workflow and remote development](Day1/23_vscode_remote_dev/vs_code_workflow.ipynb) (@Victor) **11:45-12:30**
  - VSCode editor
  - Remote development

- 💻 Additional exercises

### Lunch
**12:30 - 13:30**

### Afternoon session 3
**13:30 - 15:00**

- 🎤 **Talk** Overview of the ecosystem (@Mauro) **13:30-13:45**
  - the Julia discourse,
  - the packages we like best,

- 🎤 💻 [`DataFrames`, broadcasting, loading CSV](Day1/32_dataframe_tuto/32_dataframe_tuto.ipynb) (@Victor) **13:45-14:05**


- 💻 [Hands-on exercises](Day1/32_dataframe_tuto/33_dataframe_exercises.md) **14:05-14:30**


- 🎤 💻 Plotting and visualisation (@Mauro) **14:30-14:45**

- 💻 [Hands-on exercises continued](Day1/32_dataframe_tuto/33_dataframe_exercises.md) **14:45-15:00**

### Coffee break
**15:00 - 15:30**

### Afternoon session 4
- 🎤 [Why I like Julia](https://github.com/luraess/WSLJulia2023) (@Ludovic) **15:30-15:40**
- 🎤 💻 Saving and loading data in Julia (Mauro) **-15:40-15:55**
- 💻 Hands-on exercises **15:55-17:00**
  - [Coding the game of life](Day1/42_game_of_life/42_game_of_life.md)
  - Continuing previous exercises



### 🍻 Apéro
**17:00-🌙**

## Day 2: Project-oriented day

The goal of this second-day workshop is to provide participants with an opportunity to deepen their knowledge of the Julia programming language through biodiversity and glaciology-related projects.

### Morning session 1

- 🎤 💻 Geospatial data handling (@Mauro) **9:00-9:30**
  - Rasters with Raster.jk
  - shapefiles
  - Hands-on exercises

- 🎤 💻 Performant Julia code and profiling (@Mauro) **9:30-10:00**
  - Introduction
  - Hands-on exercises


- 🎤 💻 [Parallel computing](Day2/12_parallel_computing/parallel_computing.md) (@Victor) **10:00-10:30**
  - Multithreading
  - Multiprocessing
  - Exercise: Parallelizing the code of life.





### Coffee break
**10:30-11:00**

### Morning session 2
- 💻 Hands-on exercises **11:00-11:30**

- 🎤 Interface with Python, R, MATLAB (@Victor) **11:30-12:00**

- 🎤 Track Introductions (@Victor and @Mauro) **12:00-12:30**
  - Biodiversity track
  - Glaciology track


### Lunch

### Afternoon session 3
- 💻 Project session **13:30-15:00**

### Coffee break 
**15:00-15:30**

### Afternoon session 4

- 🎤 Why I like Julia (@Ivan) **15:30-15:40**
- 💻 Project session **15:40-16:30**

- 🎤 Wrap-up and feedback **16:30 - 17:00**


# Projects
## Biodiversity track

- [Deep learning-based Species Distribution Model](Projects/Victor/ml-based-SDM/DL-based-SDM_project.md)
- [Constructing a benchmark of PiecewiseInference.jl against ApproxBayes.jl and Turing.jl]()

- [Marine ecosystem time series modelling]()

## Glaciology track

### Shallow ice model in 1D
Time scales, hysteresis. Real topo.

### Subglacial water routing
Yesterday and today (Fischer paper)?

### Ice thickness estimation
PoG exercise

# Additional resources
- [Julia official list of tutorials](https://julialang.org/learning/tutorials/)
- https://github.com/storopoli/Julia-Workshop, https://www.youtube.com/watch?v=uiQpwMQZBTA, 3 hours
- https://www.matecdev.com/posts/julia-tutorial-science-engineering.html
- https://crsl4.github.io/julia-workshop/session1-get-started.html
# Acknowledgments

The workshop materials are based on the following resources:

- [List of references or sources of inspiration]

# Contact

If you have any questions or feedback, feel free to contact the contributors @vboussange and @mauro3.
