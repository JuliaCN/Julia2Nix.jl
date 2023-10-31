{
  lib,
  version,
  julia-sources,
  system,
}:
let
  l = lib // builtins;
  version' =
    lib.elemAt
      (lib.splitString "-" julia-sources."julia-${version}-${system}".version)
      0;
  nightly =
    lib.elemAt
      (lib.splitString "-" julia-sources."julia-${version}-${system}".pname)
      1;
  major = l.substring 0 3 version';
in
{
  default = if nightly == "nightly" then "1.10" + "-${version'}" else version';
  major = if nightly == "nightly" then "1.10" else major;
}
