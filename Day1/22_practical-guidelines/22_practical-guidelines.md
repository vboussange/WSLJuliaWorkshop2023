# A practical guideline on how to work with Julia 

This session is about providing you with a nice workflow to get started with a Julia project.

## Folder structure

A typical research project in julia looks like that
- `code/`
- `data/`
- `run_code.sh`
- `Manifest.toml`
- `Project.toml`
- `.gitignore`


## Packages Management

Julia has a built-in package manager called `Pkg` which can be used to install and manage packages. 

### REPL prompt
The built-in package manager in Julia is called `Pkg`. It allows users to install, update, and manage the packages used in their projects. Here's a brief overview of how it works: 
1. To use `Pkg`, start by typing `]` in the Julia REPL (read-eval-print loop). This will take you to the package manager prompt. 
2. From the package manager prompt, you can execute a variety of commands. Some of the most commonly used ones include: 
- `add`: adds a package to the current project 
- `update`: updates all packages in the current project to their latest versions 
- `activate`: switches to a different project environment 
- `instantiate`: installs all packages specified in a project's `Project.toml` file 
1. When you run `add` to install a package, `Pkg` will download and install the package, along with any dependencies it requires. It will also create a `Manifest.toml` file that specifies the exact versions of all packages that were installed, ensuring that you can reproduce your environment exactly later. 
2. To load a package in your code, you can use the `using` keyword followed by the package name. For example, to load the `CSV` package, you would write `using CSV` at the top of your code. 
3. `Pkg` also allows you to manage different versions of a package across different projects. You can create a new project environment with `Pkg` and specify which version of a package you want to use in that environment. This is useful when you have projects with different requirements for package versions.

### Scripting
```julia
using Pkg
Pkg.add("PackageName")
Pkg.update()
Pkg.rm("PackageName")
Pkg.activate("path/to/environment")
Pkg.instantiate()
Pkg.status()
```
### `Project.toml` and `Manifest.toml`
Two files that are central to Pkg are `Project.toml` and `Manifest.toml`. `Project.toml` and `Manifest.toml` are written in TOML (hence the .toml extension) and include information about dependencies, versions, package names, UUIDs etc.

#### `Project.toml`
Looks like that

```
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Flux = "587475ba-b771-5e3f-ad9e-33799f191a9c"
MLDatasets = "eb30cadb-4394-5ae3-aed4-317e484a6458"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
```
All dependencies of the package/project are listed in the [deps] section. Each dependency is listed as a name-uuid pair.

UUID is a string with a universally unique identifier for the package/project

##### Optional fields
```
[deps]
Example = "7876af07-990d-54b4-ab0e-23690620f79a"

[compat]
Example = "1.2"
```

##### Additional fields for a package
```
name = "PackageName"
uuid = "96372a6d-8f12-4b28-95ba-ac697ae6fb10"
authors = ["Victor Boussange"]
version = "0.1.0"
```

Those are generated when you do 

```
julia >] generate PackageName
```

#### `Manifest.toml`
The manifest file is an absolute record of the state of the packages in the environment. It includes exact information about (direct and indirect) dependencies of the project. Given a Project.toml + Manifest.toml pair, it is possible to instantiate the exact same package environment, which is very useful for reproducibility. For the details, see Pkg.instantiate.

When you do not care about reproducibility, you do not have to track this file. In Julia packages, this file is not provided, to be flexible with each user specific environment. However, for research project, it is sensible to track it.

### Advanced package management
You can add a package which is not registered by its remote repo address

```julia
julia>] add https://github.com/vboussange/ParametricModels.jl
```

Or its path

```julia
julia>] add path/to/my/awesome/package
```

You can also ask for a specific version of a package

```julia
julia>] add MyPackage@0.12.0
```

Note that the default environment (located somewhere at `~/.julia/environments/v1.8`) is stacked onto the project environment. This can be convenient, if you do not want to include certain dependencies in your project yet use it for some particular purposes.

A good example for that is `BenchmarkTools` package, that you may use sporadically.

```julia
using BenchmarkTools
@btime randn(100,100)
```

### Adding external registries

[Here](https://github.com/JuliaRegistries/General) is what the official registry of general Julia packages.

But you can add non-official registries as well!

```julia
using Pkg
pkg"registry add https://github.com/vboussange/VBoussangeRegistry.git"
```



## VS Code workflow
- `cmd + alt + p`: opens the command palette
- select the julia environment (blue bottom left corner)

![](https://www.julia-vscode.org/docs/dev/images/env-select.png)

- open a julia terminal
- `shift + enter`: execute a line
- `julia>?` ask for the documentation of a certain function
- checkout the git panel
- `ctrl + c`: interrupt execution
- `ctrl + d`: quit Julia
- `cmd + click on a function`: goes to the function definition
- format the code
In order to format your code press shift + cmd|windows + p to bring up the command palette and search for `Format Document`

![](https://www.julia-vscode.org/docs/dev/images/format.png)

- There is a cool table viewer

![](https://www.julia-vscode.org/docs/dev/images/table.png)

- `cmd + alt + f`: to search for a word in the entire active folde

## How to run a julia file on a remote server
The Remote-SSH development tool is very handy to boost productivity. Remote Development allows developers to directly use remote servers during the development process, instead of first developing on their local machines with limited computing resources and then modify the script so that it can run on the remote server. This also means that the local machine does not have to meet the requirements for running the development environment or storing large amounts of data.

### Remote Development using SSH
The Visual Studio Code Remote - SSH extension allows you to open a remote folder on any remote machine, virtual machine, or container with a running SSH server and take full advantage of VS Code's feature set. Once connected to a server, you can interact with files and folders anywhere on the remote filesystem.

No source code needs to be on your local machine to gain these benefits since the extension runs commands and other extensions directly on the remote machine.
![](https://code.visualstudio.com/assets/docs/remote/ssh/architecture-ssh.png)

![](https://www.julia-vscode.org/docs/dev/images/remote/remote_extensions.png)


#### More detailed resources

- [Here are guidelines to proceed](https://code.visualstudio.com/docs/remote/ssh)
Install the Remote-SSH extension. If you plan to work with other remote extensions in VS Code, you may choose to install the Remote Development extension pack.

- [Some other guidelines specific to Julia development](https://www.julia-vscode.org/docs/dev/userguide/remote/)

### Live demonstration 

Wait for it.

### My way of launching a heavy script

Once you are satisfied, you can start run the script in a new screen.

I like using a shell script to run my scripts. Here is one, called `run_code.sh`

```sh
#!/bin/bash
pathsim=$1
threads=$2
namesim=$(basename ${pathsim})

date
echo "lauching script for $namesim"
$HOME/utils/julia-1.7.2/bin/julia --project=./julia/ --threads $threads "$pathsim.jl" &> "stdout/${namesim}.out"
wait
echo "computation over"
date
```
Here's what the script does, step by step:

- Assigns the first argument to the variable pathsim and the second argument to the variable threads.
- Extracts the base name of the pathsim using the basename command and assigns it to the variable namesim.
- Prints the current date and a message indicating which simulation is being launched.
- Runs the Julia script specified by the pathsim variable using the Julia executable located in `$HOME/utils/julia-1.7.2/bin/julia`. The `--project` flag sets the project directory to ./julia/, which is the current working directory. The `--threads` flag sets the number of threads to use for computation to the value of the threads variable. The output of the Julia script is redirected to a file named `stdout/${namesim}.out`, where `${namesim}` is the base name of the `pathsim` variable.
- Waits for the Julia script to finish before continuing.
- Prints the current date and a message indicating that the computation is over.


## Acknowledgement and resources
- [Pkg.jl documentation](https://pkgdocs.julialang.org/v1/toml-files/)
- [How to set up a development environment, outside the global (default) environment, together with nice tricks for your `sartup.jl`](https://davidamos.dev/five-minutes-to-julia/)