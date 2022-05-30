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
      name = "checks-GR";
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
    {
      name = "checks-gr";
      command = ''
        nix run $PRJ_ROOT/templates/jlrs#packages.x86_64-linux.gr --print-build-logs
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
