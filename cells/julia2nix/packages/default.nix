{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std self;
  inherit (inputs.nixpkgs) lib;
  inherit (cell) library;

  test-depot = library.buildDepot {
    depot = "${(std.incl self [
      (self + "/Depot.nix")
    ])}/Depot.nix";
  };
in {
  inherit (nixpkgs) julia_17-bin julia_16-bin;
  inherit test-depot;
}
