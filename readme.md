# Practical introduction to Julia for modelling and data analysis in biodiversity and earth sciences

This repository contains materials for the [WSL Julia Workshop 2023](https://www.wsl.ch/de/ueber-die-wsl/die-wsl-im-dialog/details/practical-introduction-to-julia-for-modelling-and-data-analysis-in-biodiversity-and-earth-sciences.html) **Practical introduction to Julia for modelling and data analysis in biodiversity and earth sciences**, held on the 24th and 27th of March 2023 at WSL Birmensdorf.

# Content

The repository is organized by days and sessions. Please refer to the [Program](#program) to navigate within the repo.

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
## Day 1: Introduction to the Language, hands on exercises

**8:50** Arrival at Englersaal, WSL (ask at the reception if you don't
know where that is)

### Morning session 1
**9:00 - 10:30**

- 🎤 Greetings to the Workshop (@Mauro and @Victor) **9:00-9:10**
- 🎤 Overview of the Julia programming language (@Mauro) **9:10-9:30**
- 💻 Jupyter hub practical (@Mauro) **9:30-10:30**
  - **Practical** Basic syntax and data types
  - **Practical** Control flow and conditional statements
### Coffee break
**10:30 - 11:00**

### Morning session 2
**11-12:30**
- 🎤 **Experience** [Why I like Julia](Day1/21_why-i-like-julia-VB/21_why-i-like-julia-VB.ipynb) (@Victor) **11:00-11:30**

- 🎤 💻 **session/talk (interactive)** [A practical guideline on how to work with Julia](Day1/22_practical-guidelines/22_practical-guidelines.md) (@Victor) **11:30-12:00**
  - julia installation
  - Pkg management and environments
  - editors (vscode integration)

- 💻 **Exercises** (@Mauro) 12:00-12:30

- 💻 **Additional exercises**

### Lunch
**12:30 - 13:30**

### Afternoon session 1
**13:30 - 15:00**

- 🎤 **Talk** Overview of the ecosystem (@Mauro) **13:30-14:00**
  - the Julia discourse,
  - the packages we like best,

- 🎤 💻 **Interactive talk** [`DataFrames`, broadcasting, loading CSV](Day1/32_dataframe_tuto/32_dataframe_tuto.ipynb) (@Victor) **14:00-14:15**


- 🎤 💻 **Interactive talk**  Plotting and visualisation (@Mauro) **14:15-14:30**

- 💻 [Hands-on exercises](Day1/32_dataframe_tuto/33_dataframe_exercises.md) (@Victor) **14:30-15:00**

### Coffee break
**15:00 - 15:30**

### Afternoon session 2
- 🎤 💻 **Interactive talk** Saving and loading data in Julia (Mauro) **14:15-14:30**
- 💻 [Coding the game of life](Day1/AfternoonSession2/game_of_life.md) **14:30:16:30**
- 🧵 **Wrap-up and discussion** **16:30-17:00**



### 🍻 Apéro

## Day 2: Project-oriented day

The goal of this second-day workshop is to provide participants with an opportunity to deepen their knowledge of the Julia programming language through biodiversity and glaciology-related projects.

### Morning session 1

- Geospatial data handling (@Mauro) **9:00-9:30**
  - rasters
  - shapefiles

- Parallel computing (@Victor) **9:30-10:00**
  - threads 
  - distributed


- Profiling Julia code (@Mauro) **10:00-10:30**



### Coffee break
**10:30-11:00**

### Morning session 2
- Interface with Python, R, matlab (@Victor) **11:00-11:30**

- **Talk** Track Introductions (@Victor and @Mauro) **11:30-12:30**
  - Biodiversity track
  - Glaciology track


### Lunch

### Afternoon session 1
- Project session **13:30-15:00**



### Coffee break 
**15:00-15:30**

### Afternoon session 2 

- Project session **15:30-16:00**
- Participants will share their progress and discuss their experience working on the project. **16:00-16:45**
- Feedback **16:45 - 17:00**


# Projects
## Biodiversity track

### Hyper parameter optimization of a machine learning-based SDM

### Constructing a benchmark of PiecewiseInference.jl against ApproxBayes.jl and Turing.jl

### Marine ecosystem time series modelling

## Glaciology track

### Shallow ice model in 1D
Time scales, hysteresis. Real topo.

### Subglacial water routing
Yesterday and today (Fischer paper)?

### Ice thickness estimation
PoG exercise

# Additional resources
- Julia official list of tutorials: https://julialang.org/learning/tutorials/
- https://github.com/storopoli/Julia-Workshop, https://www.youtube.com/watch?v=uiQpwMQZBTA, 3 hours
- https://www.matecdev.com/posts/julia-tutorial-science-engineering.html
- https://crsl4.github.io/julia-workshop/session1-get-started.html
# Acknowledgments

The workshop materials are based on the following resources:

- [List of references or sources of inspiration]

# Contact

If you have any questions or feedback, feel free to contact the contributors @vboussange and @mauro3.
