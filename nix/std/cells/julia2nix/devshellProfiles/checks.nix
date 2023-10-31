{ inputs, cell }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  commands = [
    {
      name = "checks-GR";
      category = "tests";
      command = ''
        nix run .\#packages.x86_64-linux.julia-wrapped -- -e 'import Pkg; Pkg.add("GR"); using GR; histogram(randn(10000))'
      '';
    }
    {
      name = "checks-jlrs-call-julia";
      category = "tests";
      command = ''
        nix develop ./templates/jlrs --show-trace --override-input julia2nix $PRJ_ROOT --command -- call-julia
      '';
    }
  ];

  env = [
    {
      # https://forum.qt.io/topic/111553/solved-qt-qpa-plugin-could-not-find-the-qt-platform-plugin-xcb-in/22
      name = "QT_DEBUG_PLUGINS";
      value = "1";
    }
  ];
}
