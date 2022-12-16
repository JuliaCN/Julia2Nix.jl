{
  lib,
  version,
  julia-sources,
  system,
}: let
  l = lib // builtins;
  version' = lib.elemAt (lib.splitString "-" julia-sources."julia-${version}-${system}".version) 0;
in
  if version' == "nightly"
  then "nightly"
  else version'
