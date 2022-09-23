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
        name = "julia-18";
        command = "${packages.julia_18-bin}/bin/julia";
        help = packages.julia_18-bin.meta.description;
      }
    ]
    ++ lib.optionals (pkgs.system == "x86_64-darwin") [
      {
        # FIXME: 1.8.0 init issue
        package = packages.julia_17-bin;
        help = packages.julia_17-bin.version + packages.julia_17-bin.meta.description;
      }
    ]
    ++ lib.optionals (pkgs.system == "aarch64-darwin") [
      {
        package = packages.julia_18-bin;
        help = packages.julia_18-bin.version + packages.julia_18-bin.meta.description;
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isLinux [
      {
        package = packages.julia_18-bin;
        help = packages.julia_18-bin.version + " " + packages.julia_18-bin.meta.description;
      }
      {
        name = "julia-fhs";
        command = "${packages.julia-fhs}/bin/julia";
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
