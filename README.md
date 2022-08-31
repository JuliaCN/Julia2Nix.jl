# Julia2Nix

The Nix interface to Julia Pkg

# Simple Usage

## Templates

Initializing your default shellEnv of julia2nix with flake template

### default

```sh
nix flake init --template github:JuliaCN/Julia2Nix.jl#templates.devshell
## add these files in your git stage
nix develop
```

### jlrs

```sh
nix flake init --template github:JuliaCN/Julia2Nix.jl#templates.jlrs
```


# LICENSE

`Julia2nix` is licensed under the [`./LICENSE.md`][license].

