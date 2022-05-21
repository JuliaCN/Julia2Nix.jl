{pkgs ? import <nixpkgs> {}}: {
  meta = {"pkgServer" = "https://pkg.julialang.org";};
  depot = {
    "artifacts/02d9b78ed041cc654102f58897ae46fac83ca63f" = pkgs.fetchzip {
      "name" = "artifact-02d9b78ed041cc654102f58897ae46fac83ca63f";
      "sha256" = "sha256-cnWpf7v2sw5QKehDEYJ4GSATVkJkb2naRE6Ie0WiTL4=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/02d9b78ed041cc654102f58897ae46fac83ca63f#artifact.tar.gz";
    };
    "artifacts/2e8fae88dcadc37883e31246fe7397f4f1039f88" = pkgs.fetchzip {
      "name" = "artifact-2e8fae88dcadc37883e31246fe7397f4f1039f88";
      "sha256" = "sha256-lRAr3t81krlKh9H+nX0+3l0lLS8ndwth6DiZl//MDdU=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/2e8fae88dcadc37883e31246fe7397f4f1039f88#artifact.tar.gz";
    };
    "artifacts/33c5e3a13ad6427f86436f577c0edce1e468ac80" = pkgs.fetchzip {
      "name" = "artifact-33c5e3a13ad6427f86436f577c0edce1e468ac80";
      "sha256" = "sha256-yHv+b8WLS2yJKgp6tbVsvEtiki5DNBKGuXiNaRjo+Oo=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/33c5e3a13ad6427f86436f577c0edce1e468ac80#artifact.tar.gz";
    };
    "artifacts/4f01ca82b02afe6cdbe200a8f5c9849eac642482" = pkgs.fetchzip {
      "name" = "artifact-4f01ca82b02afe6cdbe200a8f5c9849eac642482";
      "sha256" = "sha256-hTvFbVORfMtTcljGl1LY7kgFXlNE5kO41v0R4IlLhFY=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/4f01ca82b02afe6cdbe200a8f5c9849eac642482#artifact.tar.gz";
    };
    "artifacts/75b2da9ed2ec48588460be0f3a8bb489212012e9" = pkgs.fetchzip {
      "name" = "artifact-75b2da9ed2ec48588460be0f3a8bb489212012e9";
      "sha256" = "sha256-7H51NyO9z23atWsvSneFbjyfrbcabGW8jwzns7pJOzg=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/75b2da9ed2ec48588460be0f3a8bb489212012e9#artifact.tar.gz";
    };
    "artifacts/dc526f26fb179a3f68eb13fcbe5d2d2a5aa7eeac" = pkgs.fetchzip {
      "name" = "artifact-dc526f26fb179a3f68eb13fcbe5d2d2a5aa7eeac";
      "sha256" = "sha256-27PVVCJaJplznvzgGGwQE3ksOuaUarHOYmDfMKSbUug=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/dc526f26fb179a3f68eb13fcbe5d2d2a5aa7eeac#artifact.tar.gz";
    };
    "artifacts/fac7e6d8fc4c5775bf5118ab494120d2a0db4d64" = pkgs.fetchzip {
      "name" = "artifact-fac7e6d8fc4c5775bf5118ab494120d2a0db4d64";
      "sha256" = "sha256-wuSLI2PZ4SczLDqodN7CYjI7hswN1ZegUo86Tvnawq4=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/fac7e6d8fc4c5775bf5118ab494120d2a0db4d64#artifact.tar.gz";
    };
    "packages/ArgParse/bylyV" = pkgs.fetchzip {
      "name" = "package-ArgParse";
      "sha256" = "sha256-qBM1thqt0id4UridMeChGWigvDVP+PuOBpSyIT9YJAs=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/c7e460c6-2fb9-53a9-8c5b-16f535851c63/3102bce13da501c9104df33549f511cd25264d7d#package.tar.gz";
    };
    "packages/CodecBase/JP712" = pkgs.fetchzip {
      "name" = "package-CodecBase";
      "sha256" = "sha256-WJ4fn9m8zlpOYS9oZSU0fwYxDTJwjujXDcIBL9IJdwo=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/6c391c72-fb7b-5838-ba82-7cfb1bcfecbf/744128fbfc6fe0739085d995b1756f1856964d4c#package.tar.gz";
    };
    "packages/CodecZlib/ruMLE" = pkgs.fetchzip {
      "name" = "package-CodecZlib";
      "sha256" = "sha256-BL6c/f/6bbbn6e3qBOWwO3+vxwv7G9P/IpNP6u0ApnY=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/944b1d66-785c-5afd-91f1-9de20f533193/ded953804d019afa9a3f98981d99b33e3db7b6da#package.tar.gz";
    };
    "packages/Expat_jll/34w3j" = pkgs.fetchzip {
      "name" = "package-Expat_jll";
      "sha256" = "sha256-76MUkP7Yx5UrJpBeauMVJ0TYCdhYJiGyF4xWei2ZBxw=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/2e619515-83b5-522b-bb60-26c02a35a201/bad72f730e9e91c08d9427d5e8db95478a3c323d#package.tar.gz";
    };
    "packages/Gettext_jll/5wIPp" = pkgs.fetchzip {
      "name" = "package-Gettext_jll";
      "sha256" = "sha256-rvbsJ0HAiGvY/CIWn0bLqEPqsqcf0PlekgaDkzafHD4=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/78b55507-aeef-58d4-861c-77aaff3498b1/9b02998aba7bf074d14de89f9d37ca24a1a0b046#package.tar.gz";
    };
    "packages/Git/EnxqL" = pkgs.fetchzip {
      "name" = "package-Git";
      "sha256" = "sha256-BqIhF5JJjruCf6jsW5YGKG1RG7FxNn3/X3sxYMb79i8=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2/d7bffc3fe097e9589145493c08c41297b457e5d0#package.tar.gz";
    };
    "packages/Git_jll/G4IMQ" = pkgs.fetchzip {
      "name" = "package-Git_jll";
      "sha256" = "sha256-rEjJehQYEKInDVQMWp4GpE//T6wqsOy4L6rRpiWgdqc=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/f8c6e375-362e-5223-8a59-34ff63f689eb/6e93d42b97978709e9c941fa43d0f01701f0d290#package.tar.gz";
    };
    "packages/HTTP/aTjcj" = pkgs.fetchzip {
      "name" = "package-HTTP";
      "sha256" = "sha256-Y//u1H8lnfQU9NpPMRmFgxjwkQq90HKoILk4DQZl3/o=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/cd3eb016-35fb-5094-929b-558a96fad6f3/0fa77022fe4b511826b39c894c90daf5fce3334a#package.tar.gz";
    };
    "packages/IniFile/LzI2G" = pkgs.fetchzip {
      "name" = "package-IniFile";
      "sha256" = "sha256-7uQSdBYwRvH3/4aKXEE6U+AEMQnPmEGgl6sZt+U6vu4=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/83e8ac13-25f8-5344-8a64-a9f2b223428f/f550e6e32074c939295eb5ea6de31849ac2c9625#package.tar.gz";
    };
    "packages/JLLWrappers/QpMQW" = pkgs.fetchzip {
      "name" = "package-JLLWrappers";
      "sha256" = "sha256-HCas3QrKJJu2CPtTfe6HLCdajP5j84fxqvXmw6BJGHk=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/692b3bcd-3c85-4b1f-b108-f13ce0eb3210/abc9885a7ca2052a736a600f7fa66209f96506e1#package.tar.gz";
    };
    "packages/JSON/NeJ9k" = pkgs.fetchzip {
      "name" = "package-JSON";
      "sha256" = "sha256-n2oLLNDn7qsRytMKXKUB653A14Yat+GiK9DgrkVBV9A=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/682c06a0-de6a-54ab-a142-c8b1cf79cde6/3c837543ddb02250ef42f4738347454f95079d4e#package.tar.gz";
    };
    "packages/Libiconv_jll/tGWLj" = pkgs.fetchzip {
      "name" = "package-Libiconv_jll";
      "sha256" = "sha256-q0+kpW58lKLih0e2I7IVeb/Um+O3LmiaqgSHQOWhPDM=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/94ce4f54-9a6c-5748-9c1c-f9c7231a4531/42b62845d70a619f063a7da093d995ec8e15e778#package.tar.gz";
    };
    "packages/MbedTLS/4YY6E" = pkgs.fetchzip {
      "name" = "package-MbedTLS";
      "sha256" = "sha256-y21+TCpKgR4xBVOlHY9AxfIfR98TswfmsETQU7JwX34=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/739be429-bea8-5141-9913-cc70e7f3736d/1c38e51c3d08ef2278062ebceade0e46cefc96fe#package.tar.gz";
    };
    "packages/OpenSSL_jll/K3gvo" = pkgs.fetchzip {
      "name" = "package-OpenSSL_jll";
      "sha256" = "sha256-g3HiNARPGon+6RGJhlKL0niPYqGYR1Jo5JTeJJ0WUHA=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/458c3c95-2e84-50aa-8efc-19380b2a3a95/ab05aa4cc89736e95915b01e7279e61b1bfe33b8#package.tar.gz";
    };
    "packages/Parsers/qGW3q" = pkgs.fetchzip {
      "name" = "package-Parsers";
      "sha256" = "sha256-LZp9OTs58Hl6ixSo+9NCz4PjdNOz5ZHYkytxXYWSXBg=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/69de0a69-1ddd-5017-9359-2bf0b02dc9f0/1285416549ccfcdf0c50d4997a94331e88d68413#package.tar.gz";
    };
    "packages/Preferences/VmJXL" = pkgs.fetchzip {
      "name" = "package-Preferences";
      "sha256" = "sha256-xLlPqNWnuXQX03jlVyaDW4X6HEWgCJrv448gDHPQSbk=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/21216c6a-2e73-6563-6e65-726566657250/47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d#package.tar.gz";
    };
    "packages/TextWrap/DsImh" = pkgs.fetchzip {
      "name" = "package-TextWrap";
      "sha256" = "sha256-vn0TEXG+NUvX+SDKkdhbV6o0KAampR+wtNUan1yKkNo=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/b718987f-49a8-5099-9789-dcd902bef87d/9250ef9b01b66667380cf3275b3f7488d0e25faf#package.tar.gz";
    };
    "packages/TranscodingStreams/IVlnc" = pkgs.fetchzip {
      "name" = "package-TranscodingStreams";
      "sha256" = "sha256-iCwJg808LzR47Sa7VCnro7iz35NIQEdZxIqNJGKkc/A=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/3bb67fe8-82b1-5028-8e26-92a6c54297fa/216b95ea110b5972db65aa90f88d8d89dcb8851c#package.tar.gz";
    };
    "packages/URIs/o9DQG" = pkgs.fetchzip {
      "name" = "package-URIs";
      "sha256" = "sha256-Iq2ChHRpXLnsI+EIBtXcpCc6RnP4R0arFnXaOceD5E4=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4/97bbe755a53fe859669cd907f2d96aee8d2c1355#package.tar.gz";
    };
    "packages/XML2_jll/8hNQM" = pkgs.fetchzip {
      "name" = "package-XML2_jll";
      "sha256" = "sha256-1TpUk8ayDBZyqoNMqeYuZlfNqkptFrA5Mx2LXXJx3Lw=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a/1acf5bdf07aa0907e0a37d3718bb88d4b687b74a#package.tar.gz";
    };
    "registries/General" = pkgs.fetchzip {
      "name" = "registry-General";
      "sha256" = "sha256-xNlNPjbGTA+alSIkxeXVyDOBwtluDubN04U18z38a7k=";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/registry/23338594-aafe-5451-b93e-139f81909106/3d984b03dbd6f00f0c586c2417db27d6f4348a81#registry.tar.gz";
    };
  };
}
