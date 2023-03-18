# Installation instructions

## Installing Julia with `juliaup`
We strongy recommend using [juliaup](https://github.com/JuliaLang/juliaup) to install Julia.

### Windows

On Windows Julia and Juliaup can be installed directly from the Windows store [here](https://www.microsoft.com/store/apps/9NJNWW8PVKMN). One can also install exactly the same version by executing

```
winget install julia -s msstore
```

in a command line.

If the Windows Store is blocked on a system, we have an alternative [MSIX App Installer](https://learn.microsoft.com/en-us/windows/msix/app-installer/app-installer-file-overview) based setup. Note that this is currently experimental, please report back successes and failures [here](https://github.com/JuliaLang/juliaup/issues/343). To use the App Installer version, download [this](https://install.julialang.org/Julia.appinstaller) file and open it by double clicking on it.

### MacOS and Linux

Juliaup can be installed on Linux or Mac by executing

```
curl -fsSL https://install.julialang.org | sh
```

in a shell.

### Mac and `brew`

An alternative on MacOS is to use the `brew` manager, if you have it already installed

```
brew install juliaup
```

## Installing VS Code

You can download VS Code [here](https://code.visualstudio.com/download). Note that it is also available with `brew`.

You then need to install the Julia extension. You'll find [here](https://code.visualstudio.com/docs/languages/julia) some instructions on the Julia extension, and how to use. We'll also cover that in the workshop. 
