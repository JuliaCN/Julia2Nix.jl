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
        nvfetcher-update nix/julia2nix/packages/toolchain/sources.toml
        if [[ ! -n "$(git diff HEAD --unified=0 | grep 'sha256')" && -n "''${GITHUB_ENV}" ]]; then
           unset GITHUB_ENV
        fi
      '';
      help = "Generate nix sources expr for the latest version of packages";
    }
  ];
}
