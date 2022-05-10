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
      }
    ]
    ++ lib.optionals pkgs.stdenv.buildPlatform.isDarwin [
      {
        package = inputs.self.packages.${pkgs.system}.julia_17-bin;
      }
    ];
}
