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
git clone https://github.com/[username]/[repository-name].git
```
Then, navigate to the cloned repository and start a Julia session. You can run the examples and exercises in the notebooks by opening them in Jupyter or Pluto:


```julia
using IJulia # if you installed Jupyter notebooks
notebook(dir="notebooks/")
```

# Program
## Day 1
**Goals** Introduction to the Language, hands on exercises 

### Morning session 1
**9:00 - 10:30**

- 🎤 Welcome and Introduction to the Workshop + language (@Mauro and @Victor) **9:00-9:10** 
- 🎤 Overview of the Julia programming language (@Mauro) **9:10-9:30** 
- 💻 Jupyter hub practical (@Mauro) **9:30-10:30**
  - **Practical** Basic syntax and data types
  - **Practical** Control flow and conditional statements
### Coffee break
**10:30 - 11:00**
<!-- - **9:30-10:30 Talk** Overview of the Julia Programming Language and Why We Like It
 -->
### Morning session 2
**11-12:30**
- 🎤 **Experience** Why I like Julia (@Victor) **11:00-11:30** 

- 🎤 💻 **session/talk (interactive)** A practical guideline on how to work with Julia (Victor) **11:30-12:00**
  - julia installation
  - Pkg management
  - editors (vscode integration)

- 💻 **Exercises** Prepare some exercises (@Mauro) 
  
- 💻 **Additional exercises**

### Lunch
**12:30 - 13:30**

### Afternoon session 1
**13:30 - 15:00**

- 🎤 **Talk** Overview of the ecosystem (@Mauro) **13:30-14:00**
  - the Julia discourse, 
  - the packages we like best, 

- 🎤 💻 **Interactive talk** Arrays, dataframes, loading (@Victor) **14:00-14:15**
  - indexing and slicing, 
  - matrix operations, and 
  - broadcasting
  - Importing CSV


- 🎤 💻 **Interactive talk**  Plotting and visualisation (@Mauro) **14:15-14:30**

- 💻 Hands-on exercises **14:30-15:00**

### Coffee break
15:00 - 15:30

### Afternoon session 2
- 🎤 💻 **Interactive talk** Saving and loading data in Julia (Mauro) **14:15-14:30**
- 💻 [Coding the game of life](Day1/AfternoonSession2/game_of_life.md) **14:30:16:30**
- 🧵 **Wrap-up and discussion** **16:30-17:00**


  
### 🍻 Apéro

## Day 2
**Goal** Project-oriented day

The goal of this second-day workshop is to provide participants with an opportunity to deepen their knowledge of the Julia programming language through biodiversity and glaciology-related projects.

### Morning session 1
- Raster data, shapefiles, etc... (1:00)

### Coffee break

### Morning session 2
- Interface with Python, R, matlab (30 min)

- **Talk** Track Introductions
  - Biodiversity track
  - Glaciology track
### Lunch

### Afternoon session 1



### Coffee break

### Afternoon session 2
- **Q&A**
- Participants will share their progress and discuss their experience working on the project.


# Projects
## Biodiversity track

### Project 1
Hyper parameter optimization of a machine learning based SDM.

### Project 2
Constructing a benchmark of PiecewiseInference.jl against ApproxBayes.jl and Turing.jl.

### Project 3
Marine ecosystem time series modelling.


# Additional resources
- Julia official list of tutorials: https://julialang.org/learning/tutorials/
- https://github.com/storopoli/Julia-Workshop, https://www.youtube.com/watch?v=uiQpwMQZBTA, 3 hours
- https://www.matecdev.com/posts/julia-tutorial-science-engineering.html
- https://crsl4.github.io/julia-workshop/session1-get-started.html
# Acknowledgments

The workshop materials are based on the following resources:

- [List of references or sources of inspiration]
# License

The workshop materials are released under the [license type] license. See the LICENSE file for more details.

# Contact

If you have any questions or feedback, feel free to contact the workshop organizers at [contact email or website].