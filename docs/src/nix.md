# Nix

### Nix flake struct

```
Julia2Nix.jl
├───devShells
│   ├───aarch64-darwin
│   │   ├───default: development environment 'Julia2Nix'
│   │   └───packages: development environment 'devshell'
│   ├───aarch64-linux
│   │   ├───default: development environment 'Julia2Nix'
│   │   └───packages: development environment 'devshell'
│   ├───x86_64-darwin
│   │   ├───default: development environment 'Julia2Nix'
│   │   └───packages: development environment 'devshell'
│   └───x86_64-linux
│       ├───default: development environment 'Julia2Nix'
│       └───packages: development environment 'devshell'
├───overlays
│   ├───aarch64-darwin: Nixpkgs overlay
│   ├───aarch64-linux: Nixpkgs overlay
│   ├───default: Nixpkgs overlay
│   ├───x86_64-darwin: Nixpkgs overlay
│   └───x86_64-linux: Nixpkgs overlay
├───packages
│   ├───aarch64-darwin
│   │   └───julia_18-bin: package 'julia-18-release-aarch64-darwin'
│   ├───x86_64-darwin
│   │   ├───build-project: package 'Julia2Nix'
│   │   ├───julia_17-bin: package 'julia-17-release-x86_64-darwin'
│   │   └───julia_18-bin: package 'julia-18-release-x86_64-darwin'
│   └───x86_64-linux
│       ├───build-conda: package 'build-conda'
│       ├───build-depot: package 'julia-depot'
│       ├───build-env: package 'Julia2Nix'
│       ├───build-project: package 'Julia2Nix'
│       ├───conda: package 'conda-install'
│       ├───gr: julia package 'GR'
│       ├───julia-fhs: package 'julia' with FHS
│       ├───julia-wrapped: package 'julia'
│       ├───julia2nix: package 'julia2nix'
│       ├───julia2nix-all: package 'julia2nix-all'
│       ├───julia_16-bin: package 'julia-bin-1.6.6'
│       ├───julia_17-bin: package 'julia-17-release-x86_64-linux-1.7.3-linux-x86_64'
│       └───julia_18-bin: package 'julia-18-release-x86_64-linux-1.8.1-linux-x86_64'
└───templates
    ├───devshell: template: The devshell template which contains several Julia Packages
    └───jlrs: template: The tempalte which contains jlrs development of Nix
```

You can simply use `nix run` and `nix build` to run or build them
