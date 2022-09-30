# dev shell


### commands

You can run menu in devshell to see the following 
([source](https://github.com/JuliaCN/Julia2Nix.jl/blob/main/nix/julia2nix/devshells/default.nix))

Format all jl files in the current directory
```
jlfmt
```

Run `pkgs.instantiate()` in project
```
init
```

Run julia inside FHS
```
julia-fhs
```

write julia2nix.toml with buildProject
```
buildProject
```

write julia2nix.toml in current project directory
```
writejulia2nix
```

Check `histogram(randn(10000))` in julia,
[GR](https://github.com/jheinen/GR.jl) is it running normally
```
checks-GR
```

### direnv
Enable [direnv](https://github.com/nix-community/nix-direnv)
so that you can automatically enter devshell when you enter the project directory
