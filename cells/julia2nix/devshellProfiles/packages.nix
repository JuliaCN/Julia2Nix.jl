{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (cell) packages;
in {
  commands =
    [
      {
        name = "julia18";
        command = "${packages.julia_18-bin}/bin/julia";
        help = packages.julia_18-bin.meta.description;
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isDarwin [
      {
        package = packages.julia_17-bin;
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isLinux [
      {
        package = packages.julia_17-bin;
      }
    ];

  packages = with pkgs;
    lib.optionals pkgs.stdenv.isLinux []
    ++ [
      alejandra
      nixUnstable
      nix-prefetch
      cacert # Needed for network access
    ];
  env = [
    {
      name = "NIX_PATH";
      value = "nixpkgs=${pkgs.path}";
    }
  ];
}
