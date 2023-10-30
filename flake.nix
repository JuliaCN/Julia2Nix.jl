{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    call-flake.url = "github:divnix/call-flake";
  };
  outputs = inputs: let
    std = inputs.call-flake ./nix/std;
      eachSystem = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
  in (eachSystem (system: std.${system})) // {
    inherit (std) lib packages devShells overlays;
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
