{
  config,
  lib,
  pkgs,
  ...
}: {
  commands = [
    {
      name = "GR";
      command = ''
        nix run .\#packages.x86_64-linux.julia-wrapped -- -e 'import Pkg; Pkg.add("GR"); using GR; histogram(randn(10000))'
      '';
    }
  ];
}
