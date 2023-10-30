{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-julia.url = "github:NixOS/nixpkgs/?ref=refs/pull/225513/head";
    call-flake.url = "github:divnix/call-flake";
  };
  outputs =
    inputs:
    let
      std = inputs.call-flake ./nix/std;
      eachSystem = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      src = std.inputs.omnibus.inputs.flops.haumea.pops.default.setInit {
        load = {
          src = ./nix/src;
          inputs = std.inputs // inputs;
        };
      };
    in
    (eachSystem (system: std.${system}))
    // {
      inherit (std)
        lib
        packages
        devShells
        overlays
      ;
      templates = {
        devshell = {
          description = "The devshell template which contains several Julia Packages";
          path = ./templates/dev;
        };
        jlrs = {
          description = "The tempalte which contains jlrs development of Nix";
          path = ./templates/jlrs;
        };
      };
    };
}
