{
  stdenv,
  lib,
  autoPatchelfHook,
  julia-sources,
  julia_17-bin,
  source,
}:
stdenv.mkDerivation {
  inherit (julia-sources."julia-18-beta-${source}") src pname version;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  dontStrip = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    mv {bin,etc,include,lib,libexec,share} $out
    mv LICENSE.md $out

    runHook postInstall
  '';
}
