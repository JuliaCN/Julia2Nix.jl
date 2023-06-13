{
  inputs,
  cell,
}: let
  inherit (inputs) std self;

  l = inputs.nixpkgs.lib // builtins;

  src = std.incl self [
    "src"
    "julia2nix.toml"
    "Project.toml"
    "Manifest.toml"
  ];

  nixpkgs = inputs.nixpkgs.appendOverlays [
    cell.overlays.default
  ];
in {
  inherit (nixpkgs) gr conda;

  julia-fhs = nixpkgs.julia-fhs "julia" "julia";

  julia_17-bin = (version:
    l.optionalAttrs (nixpkgs.system == "x86_64-darwin" || nixpkgs.system == "aarch64-darwin")
    (cell.lib.installApp {
      inherit version;
    })
    // l.optionalAttrs (nixpkgs.system == "aarch64-linux" || nixpkgs.system == "x86_64-linux") (cell.lib.installBin {
      inherit version;
    })) "17";

  julia_19-bin = (version:
    l.optionalAttrs (nixpkgs.system == "aarch64-darwin" || nixpkgs.system == "x86_64-darwin") (cell.lib.installApp {
      inherit version;
    })
    // l.optionalAttrs (nixpkgs.system == "x86_64-linux" || nixpkgs.system == "aarch64-linux") (cell.lib.installBin {
      inherit version;
    })) "19";

  julia_nightly-bin = (version:
    l.optionalAttrs (nixpkgs.system == "aarch64-darwin" || nixpkgs.system == "x86_64-darwin") (cell.lib.installApp {
      inherit version;
    })
    // l.optionalAttrs (nixpkgs.system == "x86_64-linux" || nixpkgs.system == "aarch64-linux") (cell.lib.installBin {
      inherit version;
    })) "nightly-110";

  julia-wrapped = cell.lib.julia-wrapped {
    package = cell.packages.julia_19-bin;
    enable = {
      GR = true;
      python =
        inputs.nixpkgs.python3.buildEnv.override
        {
          extraLibs = with inputs.nixpkgs.python3Packages; [xlrd matplotlib pyqt5];
          ignoreCollisions = true;
        };
    };
  };

  build-depot = cell.lib.buildDepot {
    julia2nix = "${std.incl self ["julia2nix.toml"]}/julia2nix.toml";
  };

  build-conda = cell.lib.buildEnv {
    src = "${std.incl self ["testenv"]}/testenv/conda";
    name = "build-conda";
    package = cell.packages.julia-wrapped;
    extraInstallPhase = with nixpkgs; ''
    '';
  };

  build-project = cell.lib.buildProject {
    inherit src;
    name = "julia-wrapped-julia2nix";
    package = cell.lib.julia-wrapped {
      extraBuildInputs = with inputs.nixpkgs; [alejandra nixUnstable nix-prefetch cacert];
    };
    saveRegistry = true;
  };

  julia2nix = inputs.std-ext.writers.lib.writeShellApplication {
    name = "julia2nix";
    runtimeInputs = [cell.packages.build-project];
    text = ''
      export NIX_PATH=${inputs.nixpkgs-lock.outPath}
      julia ${std.incl self ["testenv"]}/testenv/writejulia2nix.jl ${nixpkgs.system}
    '';
  };

  julia2nix-all = inputs.std-ext.writers.lib.writeShellApplication {
    name = "julia2nix-write-all-systems";
    runtimeInputs = [cell.packages.build-project];
    text = ''
      julia ${std.incl self ["testenv"]}/testenv/writejulia2nix.jl"
    '';
  };

  build-env = cell.lib.buildEnv {
    inherit src;
    name = "Example-PackageDeps";
    package = cell.packages.julia-wrapped;
  };
}
