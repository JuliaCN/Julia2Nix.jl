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
      name = "jlfmt";
      category = "dev";
      command = ''
        ${cell.nixago.juliaFormatter}/bin/julia -e 'import Pkg; using JuliaFormatter;format(".")'
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
