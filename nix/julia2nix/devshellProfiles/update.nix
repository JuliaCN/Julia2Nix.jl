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
        nix develop github:GTrunSec/cells-lab#devShells.x86_64-linux.update \
        --refresh --command \
        nvfetcher-update-force nix/julia2nix/packages/toolchain/sources.toml
      '';
      help = "Generate nix sources expr for the latest version of packages";
    }
  ];
}
