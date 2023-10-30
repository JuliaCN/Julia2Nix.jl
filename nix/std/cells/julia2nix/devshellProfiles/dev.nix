{
  inputs,
  cell,
}: {
  config,
  lib,
  pkgs,
  ...
}: {
  commands = lib.optionals pkgs.stdenv.buildPlatform.isLinux [
    {
      name = "jlfmt";
      category = "dev";
      help = "Julia formatter";
      command = ''
        ${cell.nixago.juliaFormatter}/bin/format.jl "$@"
      '';
    }
  ];
  env = [
    {
      name = "SSL_CERT_FILE";
      value = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    }
  ];
}
