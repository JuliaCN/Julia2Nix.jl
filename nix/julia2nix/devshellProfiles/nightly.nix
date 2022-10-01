{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: {
  commands = lib.optionals (pkgs.system != "x86_64-darwin") [
    {
      name = "julia-nightly";
      command = "${cell.packages.julia_nightly-bin}/bin/julia";
      help = "julia nightly vesio";
    }
  ];
}
