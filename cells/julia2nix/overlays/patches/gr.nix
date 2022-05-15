{
  stdenv,
  patch-sources,
  fetchurl,
  lib,
  qt5,
  libGL,
  xorg,
  system,
}: let
  mainDependencies = [
    qt5.qtbase
    qt5.qtsvg
    stdenv.cc.cc.lib
    libGL
    xorg.libXt
    xorg.libX11
    xorg.libXrender
    xorg.libXext
  ];
in
  stdenv.mkDerivation {
    name = "GR";

    version = "latest";

    inherit (patch-sources."gr-latest-${system}") pname src;

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [qt5.wrapQtAppsHook];

    installPhase = ''
      mkdir -p $out
      cp -r ./* $out
    '';

    preFixup = let
      libPath = lib.makeLibraryPath (mainDependencies
        ++ [
          xorg.libxcb
        ]);
    in ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/bin/gksqt
    '';

    propagatedBuildInputs =
      mainDependencies
      ++ [
        xorg.libxcb
        xorg.xcbproto
        xorg.xcbutil
      ];
  }
