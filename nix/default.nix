{
  lib,
  stdenv,
  nixUnstable,
  nix-prefetch,
  nixpkgs-fmt,
  glibc,
  autoPatchelfHook,
  git,
  julia,
}: let
  packageMeta = lib.importTOML ../Project.toml;
in
  stdenv.mkDerivation rec {
    pname = "julia2nix";
    version = packageMeta.version;
    src = ./.;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    dontStrip = true;
    dontConfigure = true;

    buildInputs = [
      julia
      nixUnstable
      nix-prefetch
      nixpkgs-fmt
      glibc
      git
    ];

    buildPhase = ''
      export HOME="$(pwd)"
      julia --startup-file=no --project=./. ./make.jl
    '';

    installPhase = ''
      mkdir $out
      cp -r ./build/* $out
    '';
  }
