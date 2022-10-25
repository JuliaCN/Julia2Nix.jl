# Julia2Nix.jl Documentation

The Nix interface to Julia Pkg.

# Getting started

### Shell environment

Initializing your default shellEnv of julia2nix with flake template.

```sh
nix flake init --template github:JuliaCN/Julia2Nix.jl#templates.devshell
nix develop
```

For default devshell

```sh
nix develop github:JuliaCN/Julia2Nix.jl#devShells.x86_64-linux.default
```

## Build

### julia-wrapped

`julia-wrapped` wraps the libraries and `JULIA_DEPOT_PATH`
, which can be loaded easily in a sandbox environment.

```sh
nix build .#julia-wrapped
```

### julia-fhs

`julia-fhs` run julia inside the Filesystem Hierarchy Standard.

```sh
nix build .#julia-fhs
```

## Working with a project

To build the `Manifest.toml` of packages in the project run:

```sh
nix build .#packages.<system>.build-package
# for example x86_64
nix build .#packages.x86_64-linux.build-package
```

### Generate julia2nix.toml

```sh
nix run github:JuliaCN/Julia2Nix.jl#packages.x86_64-linux.julia2nix
# Generate with all system
nix run github:JuliaCN/Julia2Nix.jl#packages.x86_64-linux.julia2nix-all
```

## Contents

```@contents
Pages = ["types.md", "junix.md", "devshell.md", "index.md"]
Depth = 2
```
