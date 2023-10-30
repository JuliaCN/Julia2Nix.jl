{ inputs }:
let
  inherit (inputs) omnibus;
  inherit
    (omnibus.lib.errors.requiredInputs inputs "jupyenv.pops" [
      "nixpkgs"
      "jupyenv"
    ])
    nixpkgs
    jupyenv
  ;
  inherit (jupyenv.lib.${nixpkgs.system}) mkJupyterlabNew;
in
{ }
