{
  inputs,
  pkgs,
}: {
  default = with pkgs;
    devshell.mkShell {
      imports = [
        (devshell.importTOML ./commands.toml)
        inputs.cheatsheet.${pkgs.system}.rust.devshellProfiles.default
        inputs.cheatsheet.${pkgs.system}.main.devshellProfiles.treefmt
      ];

      packages = [
        pkgs.rust-final
        pkgs.cargo-edit
      ];
      env = [
        {
          name = "EXTRA_JULIA_DEPOT_PATH";
          value = "${inputs.self.packages.${pkgs.system}.build-package}";
        }
      ];
    };
}
