{ inputs }:
let
  inherit (inputs) omnibus;
  inherit
    (omnibus.lib.errors.requiredInputs inputs "julia2nix.pops" [
      "nixpkgs"
      "jupyenv"
    ])
    nixpkgs
    jupyenv
  ;
  inherit (jupyenv.lib.${nixpkgs.system}) mkJupyterlabNew;
in
{
  inherit mkJupyterlabNew;
}
