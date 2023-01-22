# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  julia-17-aarch64-darwin = {
    pname = "julia-17-aarch64-darwin";
    version = "1.7.2-macaarch64.dmg";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/mac/aarch64/1.7/julia-1.7.2-macaarch64.dmg";
      sha256 = "sha256-Qg2OODnD45QH9TZc6zv7hImaRAkV7IljkFaAFbP/pLk=";
    };
  };
  julia-17-aarch64-linux = {
    pname = "julia-17-aarch64-linux";
    version = "1.7.2-macaarch64.dmg";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/linux/aarch64/1.7/julia-1.7.3-linux-aarch64.tar.gz";
      sha256 = "sha256-2eizQsgK0TcVIO1tEfVbeKpgdGc3+/V+yv1qI7Ut1x0=";
    };
  };
  julia-17-x86_64-darwin = {
    pname = "julia-17-x86_64-darwin";
    version = "1.7.3-mac64.dmg";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/mac/x64/1.7/julia-1.7.3-mac64.dmg";
      sha256 = "sha256-Z3mewGz1e8qAqKHG5aFwSF07/ARhshdpmwcw2jfQZW8=";
    };
  };
  julia-17-x86_64-linux = {
    pname = "julia-17-x86_64-linux";
    version = "1.7.3-linux-x86_64.tar.gz";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz";
      sha256 = "sha256-my9PoS2StNzF0R3Gb7EYxHaBp209+NoGTMl1c/L1xzk=";
    };
  };
  julia-18-aarch64-darwin = {
    pname = "julia-18-aarch64-darwin";
    version = "1.8.5-macaarch64.dmg";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/mac/aarch64/1.8/julia-1.8.5-macaarch64.dmg";
      sha256 = "sha256-f2ojpKHYZPaeZbFUL9PRzzJNWckirEOASxugd7nMR10=";
    };
  };
  julia-18-aarch64-linux = {
    pname = "julia-18-aarch64-linux";
    version = "1.8.5-linux-aarch64.tar.gz";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/linux/aarch64/1.8/julia-1.8.5-linux-aarch64.tar.gz";
      sha256 = "sha256-ofY3tExx6pvJbXw+80dyTAVKHlInuYCt6/wzWZ5RU6Q=";
    };
  };
  julia-18-x86_64-darwin = {
    pname = "julia-18-x86_64-darwin";
    version = "1.8.5-mac64.dmg";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/mac/x64/1.8/julia-1.8.5-mac64.dmg";
      sha256 = "sha256-Iq/V4oqKgJ3HvgvJnPSRORoxr1ZpsXPPMxjkMydBSNs=";
    };
  };
  julia-18-x86_64-linux = {
    pname = "julia-18-x86_64-linux";
    version = "1.8.5-linux-x86_64.tar.gz";
    src = fetchurl {
      url = "https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.5-linux-x86_64.tar.gz";
      sha256 = "sha256-5xokgW6P6dX0gHZky7tCc49aqf4FOX01yB1MXWSbnQU=";
    };
  };
  julia-nightly-110-aarch64-darwin = {
    pname = "julia-nightly-110-aarch64-darwin";
    version = "57101cfddb";
    src = fetchurl {
      url = "https://julialangnightlies-s3.julialang.org/bin/macos/aarch64/1.10/julia-57101cfddb-macos-aarch64.dmg";
      sha256 = "sha256-weyipC9e0Thg8v6K3s0FU5tBQdRSPNqui5waScude+0=";
    };
  };
  julia-nightly-110-aarch64-linux = {
    pname = "julia-nightly-110-aarch64-linux";
    version = "57101cfddb";
    src = fetchurl {
      url = "https://julialangnightlies-s3.julialang.org/bin/linux/aarch64/1.10/julia-57101cfddb-linux-aarch64.tar.gz";
      sha256 = "sha256-YzJCJEcQst+4QlRWj8F4LgwbKKZ/PzVXY4wsmoh0p5I=";
    };
  };
  julia-nightly-110-x86_64-darwin = {
    pname = "julia-nightly-110-x86_64-darwin";
    version = "57101cfddb";
    src = fetchurl {
      url = "https://julialangnightlies-s3.julialang.org/bin/macos/x86_64/1.10/julia-57101cfddb-macos-x86_64.dmg";
      sha256 = "sha256-E7USIOPlKvyPoRJX9PvXSQbUe4o6NyuuppUyFxasQn4=";
    };
  };
  julia-nightly-110-x86_64-linux = {
    pname = "julia-nightly-110-x86_64-linux";
    version = "57101cfddb";
    src = fetchurl {
      url = "https://julialangnightlies-s3.julialang.org/bin/linux/x86_64/1.10/julia-57101cfddb-linux-x86_64.tar.gz";
      sha256 = "sha256-7jg2LItlFgxguFJcns46QBbOkhF8fMiTAmvxPosM0qo=";
    };
  };
}
