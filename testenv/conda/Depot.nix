{pkgs ? import <nixpkgs> {}}: {
  meta = {"pkgServer" = "https://pkg.julialang.org";};
  depot = {
    "packages/Conda/x2UxR" = pkgs.fetchzip {
      "name" = "package-Conda";
      "sha256" = "sha256-NtdhqMlitgq7FJGA11WrlTvYEjO148LOJ803hv3Z/lQ=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/8f4d0f93-b110-5947-807f-2305c1781a2d/6e47d11ea2776bc5627421d59cdcc1296c058071#package.tar.gz";
    };
    "packages/JSON/NeJ9k" = pkgs.fetchzip {
      "name" = "package-JSON";
      "sha256" = "sha256-n2oLLNDn7qsRytMKXKUB653A14Yat+GiK9DgrkVBV9A=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/682c06a0-de6a-54ab-a142-c8b1cf79cde6/3c837543ddb02250ef42f4738347454f95079d4e#package.tar.gz";
    };
    "packages/Parsers/qGW3q" = pkgs.fetchzip {
      "name" = "package-Parsers";
      "sha256" = "sha256-LZp9OTs58Hl6ixSo+9NCz4PjdNOz5ZHYkytxXYWSXBg=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/69de0a69-1ddd-5017-9359-2bf0b02dc9f0/1285416549ccfcdf0c50d4997a94331e88d68413#package.tar.gz";
    };
    "packages/VersionParsing/2LjYI" = pkgs.fetchzip {
      "name" = "package-VersionParsing";
      "sha256" = "sha256-/nx6d8n0hpwGr42bz0bCd97KWwdjiH7ME+Xp0PrhzUY=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/81def892-9a0e-5fdd-b105-ffc91e053289/58d6e80b4ee071f5efd07fda82cb9fbe17200868#package.tar.gz";
    };
    "registries/General" = pkgs.fetchzip {
      "name" = "registry-General";
      "sha256" = "sha256-yeN3GZ1A8EIvxuSn9yO88wGAZ7CSeQi0IDJdjSu3Ub4=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/registry/23338594-aafe-5451-b93e-139f81909106/4fb7cae4c04af6da3d17af84351c9952b88e596d#registry.tar.gz";
    };
  };
}
