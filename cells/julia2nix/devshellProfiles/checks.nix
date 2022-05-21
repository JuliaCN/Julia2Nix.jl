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
      name = "GR";
      category = "tests";
      command = ''
        nix run .\#packages.x86_64-linux.julia-wrapped -- -e 'import Pkg; Pkg.add("GR"); using GR; histogram(randn(10000))'
      '';
    }
    {
      name = "jlrs-call-julia";
      category = "tests";
      command = ''
        cd $PRJ_ROOT/templates/jlrs/call_julia
        nix run $PRJ_ROOT/templates/jlrs#packages.x86_64-linux.call-julia --print-build-logs
      '';
    }
  ];
}
