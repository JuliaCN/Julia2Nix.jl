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
      name = "nvfetcher-update";
      command = ''
        if [ ! -d $HOME/ghq/github.com/JuliaLang/julia/.git ]; then
        ${lib.getExe pkgs.ghq} get https://github.com/JuliaLang/julia
        fi
        nix develop github:GTrunSec/std-ext#devShells.x86_64-linux.update \
        --refresh --command \
        nvfetcher-update nix/julia2nix/packages/toolchain/sources.toml
      '';
      help = "Generate nix sources expr for the latest version of packages";
    }
  ];
}
