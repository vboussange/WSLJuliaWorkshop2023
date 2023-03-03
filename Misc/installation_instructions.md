# Installation instructions

## Installing Julia
We strongy recommend using [juliaup](https://github.com/JuliaLang/juliaup) to install Julia.

### Windows

On Windows Julia and Juliaup can be installed directly from the Windows store [here](https://www.microsoft.com/store/apps/9NJNWW8PVKMN). One can also install exactly the same version by executing

```
winget install julia -s msstore
```

on a command line.

If the Windows Store is blocked on a system, we have an alternative [MSIX App Installer](https://learn.microsoft.com/en-us/windows/msix/app-installer/app-installer-file-overview) based setup. Note that this is currently experimental, please report back successes and failures [here](https://github.com/JuliaLang/juliaup/issues/343). To use the App Installer version, download [this](https://install.julialang.org/Julia.appinstaller) file and open it by double clicking on it.

### Mac and Linux

Juliaup can be installed on Linux or Mac by executing

```
curl -fsSL https://install.julialang.org | sh
```

in a shell.

#### Command line arguments

One can pass various command line arguments to the Julia installer. The syntax for installer arguments is

```bash
curl -fsSL https://install.julialang.org | sh -s -- <ARGS>
```

Here `<ARGS>` should be replaced with one or more of the following arguments:
- `--yes` (or `-y`): Run the installer in a non-interactive mode. All configuration values use their default.
- `--default-channel <NAME>`: Configure the default channel. For example `--default-channel lts` would install the `lts` channel and configure it as the default.

#### Software Repositories

**Important note:** As of now, we strongly recommend to install Juliaup via the `curl` command above rather than through OS-specific software repositories (see below) as the Juliaup variants provided by the latter currently have some drawbacks (that we hope to lift in the future).

##### [Homebrew](https://brew.sh)

```
brew install juliaup
```

##### [Arch Linux - AUR](https://aur.archlinux.org/packages/juliaup/)

On Arch Linux, Juliaup is available [in the Arch User Repository (AUR)](https://aur.archlinux.org/packages/juliaup/).

##### [openSUSE Tumbleweed](https://get.opensuse.org/tumbleweed/)

On openSUSE Tumbleweed, Juliaup is available. To install, run with root privileges:

```sh
zypper install juliaup
```

## Installing VS Code

You can download VS Code [here](https://code.visualstudio.com/download). Note that it is also available with `brew`.

You then need to install the Julia extension. You'll find [here](https://code.visualstudio.com/docs/languages/julia) some instructions on the Julia extension, and how to use. We'll also cover that in the workshop. 
