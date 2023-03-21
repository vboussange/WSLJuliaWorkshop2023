# Installation instructions

To follow the workshop materials, you need to have the following softwares installed on your computer:
1) Julia
2) Jupyter

Additionally, we recommend using
3) VSCode

as an integrated development environment (IDE, e.g. RStudio for the R language), together with its Julia extension.

You'll find installation instructions below for different platforms.

## 1) Installing Julia

We strongly recommend using [juliaup](https://github.com/JuliaLang/juliaup) to install Julia. `juliaup` is a cross-platform installer for the Julia programming language, that allows to manage different Julia version, and e.g. update the Julia version when the installed version is outdated.

In case juliaup does not work for you, refer to the section [Installing Julia without `juliaup`](#installing-julia-without-juliaup)
### Installing Julia with `juliaup`
The following will launch a script that installs `juliaup` on your machine, and subsequently install the latest version of Julia.

#### Windows

On Windows Julia and Juliaup can be installed directly from the Windows store [here](https://www.microsoft.com/store/apps/9NJNWW8PVKMN). One can also install exactly the same version by executing

```
winget install julia -s msstore
```

in a command line.

If the Windows Store is blocked on a system, an alternative using an [MSIX App Installer](https://learn.microsoft.com/en-us/windows/msix/app-installer/app-installer-file-overview) based setup. Note that this is currently experimental, please report back successes and failures [here](https://github.com/JuliaLang/juliaup/issues/343). To use the App Installer version, download [this](https://install.julialang.org/Julia.appinstaller) file and open it by double clicking on it.

#### MacOS and Linux

`juliaup` can be installed on Linux or Mac by executing

```
curl -fsSL https://install.julialang.org | sh
```

in a shell.

#### Mac and `brew`

An alternative on MacOS is to use the `brew` manager, if you have it already installed:

```
brew install juliaup
```

### Installing Julia without `juliaup`
Just use the Julia official [binaries for your platform](https://julialang.org/downloads/), available from the official Julia website.


## 2) Installing Jupyter
Jupyter is an open-source web application used for creating and sharing interactive notebooks that combine live code, equations, visualizations, and narrative text. It supports various programming languages, including Python, R, and Julia.

If you do not yet have it yet installed on your laptop, please proceed to the following instructions.

Open Julia in a terminal

```shell
julia
```

Then inside the REPL type
```julia
using Pkg
```
Then install the IJulia package by typing:

```julia
Pkg.add("IJulia")
```

To make sure that everything runs smoothly, run Jupyter. To do so, type in the REPL
```julia
using IJulia
notebook()
```
This should open a webpage on your favorite web explorer.

## 3) Installing VS Code (or another editor)

You can download VS Code [here](https://code.visualstudio.com/download). Note that it is also available with `brew`.

You then need to install the Julia extension. You'll find [here](https://code.visualstudio.com/docs/languages/julia) some instructions on the Julia extension, and how to use. We'll also cover that in the workshop.

You are welcome to use a different editor/IDE (Mauro uses Emacs), however, we will not be able to give support for those.  There are plugins/extensions for a few editors, mostly found on https://github.com/JuliaEditorSupport
