{
  lib,
  version,
}: let
  l = lib // builtins;
  v = l.head (lib.splitString "-" version);
  major = l.substring 0 1 v;
  minor = l.substring 1 2 v;
in
  if v == "nightly"
  then "nightly"
  else (major + "." + minor)
