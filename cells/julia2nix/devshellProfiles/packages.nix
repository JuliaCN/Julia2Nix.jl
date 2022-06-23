{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (cell) apps;
in {
  commands =
    [
      {
        name = "julia-18";
        command = "${apps.julia_18-bin}/bin/julia";
        help = apps.julia_18-bin.meta.description;
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isDarwin [
      {
        package = apps.julia_17-bin;
        help = apps.julia_17-bin.version + apps.julia_17-bin.meta.description;
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isLinux [
      {
        package = apps.julia_17-bin;
        help = apps.julia_17-bin.version + " " + apps.julia_17-bin.meta.description;
      }
      {
        name = "julia-fhs";
        command = "${apps.julia-fhs}/bin/julia";
        help = "julia with FHS";
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
