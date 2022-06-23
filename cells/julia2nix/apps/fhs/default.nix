{pkgs}: {
  enableJulia ? true,
  enableConda ? true,
  juliaVersion ? "julia_18",
  condaInstallationPath ? "~/.conda",
  condaJlEnv ? "conda_jl",
  pythonVersion ? "3.9",
  enableGraphical ? true,
  enableNVIDIA ? false,
  enableNode ? true,
  ...
}:
with pkgs.lib; let
  standardPackages = pkgs:
    with pkgs;
      [
        autoconf
        binutils
        clang
        cmake
        curl
        expat
        gmp
        gnumake
        gperf
        libxml2
        m4
        nss
        openssl
        stdenv.cc
        unzip
        utillinux
        which
      ]
      ++ lib.optional enableNode pkgs.nodejs;

  graphicalPackages = pkgs:
    with pkgs; [
      alsaLib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      gr
      dbus
      expat
      ffmpeg
      fontconfig
      freetype
      gdk-pixbuf
      gettext
      glfw
      glib
      glib.out
      gnome2.GConf
      gtk2
      gtk2-x11
      gtk3
      libGL
      libcap
      libgnome-keyring3
      libgpgerror
      libnotify
      libpng
      libsecret
      libselinux
      libuuid
      ncurses
      nspr
      nss
      pango
      pango.out
      pdf2svg
      qt4
      systemd
      xorg.libICE
      xorg.libSM
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
      xorg.libXrender
      xorg.libXt
      xorg.libXtst
      xorg.libXxf86vm
      xorg.libxcb
      xorg.libxkbfile
      xorg.xorgproto
      zlib
    ];

  nvidiaPackages = pkgs:
    with pkgs; [
      cudatoolkit_11
      cudnn_cudatoolkit_11
      linuxPackages.nvidia_x11
    ];

  juliaPackages = pkgs: version:
    with pkgs; let
      julias = callPackage ./julia.nix {};
    in [julias."${version}"];

  condaPackages = pkgs:
    with pkgs; [(callPackage ../../overlays/patches/conda.nix {installationPath = condaInstallationPath;})];

  targetPkgs = pkgs:
    (standardPackages pkgs)
    ++ optionals enableGraphical (graphicalPackages pkgs)
    ++ optionals enableJulia (juliaPackages pkgs juliaVersion)
    ++ optionals enableConda (condaPackages pkgs)
    ++ optionals enableNVIDIA (nvidiaPackages pkgs);

  std_envvars = ''
    export EXTRA_CCFLAGS="-I/usr/include"
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export LIBARCHIVE=${pkgs.libarchive.lib}/lib/libarchive.so
  '';

  graphical_envvars = ''
    export QTCOMPOSE=${pkgs.xorg.libX11}/share/X11/locale
    export GRDIR=${pkgs.gr}
  '';

  python = pkgs.python3.buildEnv.override {
    extraLibs = with pkgs.python3Packages; [xlrd matplotlib pyqt5];
    ignoreCollisions = true;
  };

  conda_envvars = ''
    export NIX_CFLAGS_COMPILE="-I${condaInstallationPath}/include"
    export NIX_CFLAGS_LINK="-L${condaInstallationPath}lib"
    export PATH=${condaInstallationPath}/bin:$PATH
    # source ${condaInstallationPath}/etc/profile.d/conda.sh
    export PYTHON=${python}/bin/python
    export PYTHONPATH=${python}/${pkgs.python3.sitePackages}
  '';

  conda_julia_envvars = ''
    export CONDA_JL_HOME=${condaInstallationPath}/envs/${condaJlEnv}
  '';

  nvidia_envvars = ''
    export CUDA_PATH=${pkgs.cudatoolkit_11}
    export LD_LIBRARY_PATH=${pkgs.cudatoolkit_11}/lib:${pkgs.cudnn_cudatoolkit_11}/lib:${pkgs.cudatoolkit_11.lib}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH
    export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
  '';

  envvars =
    std_envvars
    + optionalString enableGraphical graphical_envvars
    + optionalString enableConda conda_envvars
    + optionalString (enableConda && enableJulia) conda_julia_envvars
    + optionalString enableNVIDIA nvidia_envvars;

  extraOutputsToInstall = ["man" "dev"];

  multiPkgs = pkgs: with pkgs; [zlib];

  condaInitScript = ''
    conda-install
    conda create -n ${condaJlEnv} python=${pythonVersion}
  '';

  fhsCommand = commandName: commandScript:
    pkgs.buildFHSUserEnv {
      targetPkgs = targetPkgs;
      name = commandName; # Name used to start this UserEnv
      multiPkgs = multiPkgs;
      runScript = commandScript;
      extraOutputsToInstall = extraOutputsToInstall;
      profile = envvars;
    };
in
  fhsCommand
