# Installation instructions

Although you can download Julia binaries on the [official Julia website](https://julialang.org), we strongy recommend using [juliaup](https://github.com/JuliaLang/juliaup) to install Julia. `juliaup` is a cross-platform installer for the Julia programming language, that allows to manage different Julia version, and e.g. update the Julia version when the installed version is outdated. 

As an integrated development environment (IDE, e.g. RStudio for the R language), we recommend using Visual Studio Code. You'll find installation instructions below for different platforms.

## Installing Julia with `juliaup`
The following will launch a script that installs `juliaup` on your machine, and subsequently install the latest version of Julia.

### Windows

On Windows Julia and Juliaup can be installed directly from the Windows store [here](https://www.microsoft.com/store/apps/9NJNWW8PVKMN). One can also install exactly the same version by executing

```
winget install julia -s msstore
```

in a command line.

If the Windows Store is blocked on a system, an alternative using an [MSIX App Installer](https://learn.microsoft.com/en-us/windows/msix/app-installer/app-installer-file-overview) based setup. Note that this is currently experimental, please report back successes and failures [here](https://github.com/JuliaLang/juliaup/issues/343). To use the App Installer version, download [this](https://install.julialang.org/Julia.appinstaller) file and open it by double clicking on it.

### MacOS and Linux

Juliaup can be installed on Linux or Mac by executing

```
curl -fsSL https://install.julialang.org | sh
```

in a shell.

### Mac and `brew`

An alternative on MacOS is to use the `brew` manager, if you have it already installed:

```
brew install juliaup
```

### `juliaup` failing?
Just use the [binaries](https://julialang.org/downloads/) from the official Julia website.

## Installing VS Code

You can download VS Code [here](https://code.visualstudio.com/download). Note that it is also available with `brew`.

You then need to install the Julia extension. You'll find [here](https://code.visualstudio.com/docs/languages/julia) some instructions on the Julia extension, and how to use. We'll also cover that in the workshop. 
