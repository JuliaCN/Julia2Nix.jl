{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: {
  commands =
    [
      {
        name = "julia18";
        command = "${inputs.self.packages.${pkgs.system}.julia_18-beta-bin}/bin/julia";
        help = inputs.self.packages.${pkgs.system}.julia_18-beta-bin.pname;
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isDarwin [
      {
        package = inputs.self.packages.${pkgs.system}.julia_17-bin;
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isLinux [
      {
        package = inputs.self.packages.${pkgs.system}.julia_17-bin;
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
}
