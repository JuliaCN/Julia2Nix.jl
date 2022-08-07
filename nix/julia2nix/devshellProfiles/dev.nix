{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: {
  commands = [
    {
      name = "jlfmt";
      category = "dev";
      command = ''
        ${cell.nixago.juliaFormatter}/bin/julia -e 'import Pkg; using JuliaFormatter;format(".")'
      '';
    }
  ];
}
