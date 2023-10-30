{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = inputs.nixpkgs.lib // builtins;
  inherit (nixpkgs) stdenv;
  juliaFormatter = cell.lib.buildEnv {
    src = inputs.nix-filter.lib.filter {
      root = ./.;
      include = [
        ./julia2nix.toml
        ./Project.toml
        ./Manifest.toml
      ];
    };
    name = "juliaFormatter";
    # allow to format the JuliaFormatter package when compiling the package
    # use copy instead of symlink to let the package being modified in the store
    extraInstallPhase = ''
      source_file=$(dirname $(readlink $out/packages/JuliaFormatter/*/src/JuliaFormatter.jl))
      rm -rf $out/packages/JuliaFormatter/*/src
      cp -rf --no-preserve=mode,ownership $source_file $out/packages/JuliaFormatter/*/.
      mkdir -p $out/bin
      cp $out/packages/JuliaFormatter/*/bin/* $out/bin/.
      chmod +x $out/bin/*.jl
    '';
    package = cell.lib.julia-wrapped {
      makeWrapperArgs = [
        "--add-flags --compile=min"
      ];
    };
  };
in {
  inherit juliaFormatter;

  # treefmt = std-data-collection.data.configs.treefmt {
  #   data.formatter.prettier = {
  #     excludes = ["Manifest.toml" "Project.toml" "generated.json" "julia2nix.toml"];
  #   };
  #   data.formatter.nix = {
  #     excludes = ["generated.nix"];
  #   };
  #   data.formatter.julia = l.mkIf stdenv.isLinux {
  #     command = "${juliaFormatter}/bin/format.jl";
  #     includes = ["*.jl"];
  #   };
  # };
}
