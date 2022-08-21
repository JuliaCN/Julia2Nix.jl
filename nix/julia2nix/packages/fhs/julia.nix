{
  stdenv,
  lib,
  fetchurl,
  zlib,
  glib,
  xorg,
  dbus,
  fontconfig,
  freetype,
  libGL,
  julia-sources,
  system,
}: let
  makeJulia = version:
    stdenv.mkDerivation {
      name = "julia-${version}";
      inherit (julia-sources."julia-${version}-${system}") src pname version;
      installPhase = ''
        mkdir $out
        cp -R * $out/
        # Patch for https://github.com/JuliaInterop/RCall.jl/issues/339.
        echo "patching $out"
        cp -L ${stdenv.cc.cc.lib}/lib/libstdc++.so.6 $out/lib/julia/
      '';
      dontStrip = true;
      ldLibraryPath = lib.makeLibraryPath [
        stdenv.cc.cc
        zlib
        glib
        xorg.libXi
        xorg.libxcb
        xorg.libXrender
        xorg.libX11
        xorg.libSM
        xorg.libICE
        xorg.libXext
        dbus
        fontconfig
        freetype
        libGL
      ];
    };
in {
  julia_18 = makeJulia "18-release";
}
