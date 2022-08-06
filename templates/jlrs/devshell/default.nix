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
      commands = [
        {
          name = "call-julia";
          category = "tests";
          command = ''
            cd $PRJ_ROOT/templates/jlrs/call_julia
            nix run $PRJ_ROOT/templates/jlrs#packages.x86_64-linux.call-julia  --override-input julia2nix ../../.. --print-build-logs
          '';
        }
        {
          name = "julia2nix";
          category = "tests";
          command = ''
            cd $PRJ_ROOT/templates/jlrs
            nix run $PRJ_ROOT/templates/jlrs#packages.x86_64-linux.julia2nix  --override-input julia2nix ../.. --print-build-logs
          '';
        }
      ];
    };
}
