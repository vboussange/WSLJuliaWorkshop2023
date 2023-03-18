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

Overall, `Pkg` is a powerful tool that makes package management easy and reproducible in Julia.


### Scripting
Here are some basic commands: 
- To add a package:

```julia
using Pkg
Pkg.add("PackageName")
``` 
- To update packages:

```julia
Pkg.update()
``` 
- To remove a package:

```julia
Pkg.rm("PackageName")
``` 
- To activate an environment:

```julia
using Pkg
Pkg.activate("path/to/environment")
``` 
- To instantiate an environment:

```julia
using Pkg
Pkg.instantiate()
``` 
- To list all installed packages:

```julia
using Pkg
Pkg.status()
```

### Editors

Julia has good integration with various editors, including VSCode, Atom, Juno, and Jupyter notebooks. Here are some guidelines for using VSCode: 
- Install the Julia extension for VSCode. 
- Set the Julia executable path in VSCode by adding the following to your `settings.json` file:

```json
"julia.executablePath": "/path/to/julia"
``` 
- Create a Julia project in VSCode: 
- Open a new terminal in VSCode (`Ctrl` + `Shift` + `~`) 
- Navigate to the desired directory for your project 
- Activate the environment (`] activate .`) 
- Create a new project (`] generate MyProject`) 
- Open the project in VSCode (`code MyProject`) 
- To use Jupyter notebooks with Julia, install IJulia package and run the following command:

```csharp
using IJulia
notebook()
```