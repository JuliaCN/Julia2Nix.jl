{pkgs ? import <nixpkgs> {}}: {
  meta = {"pkgServer" = "https://pkg.julialang.org";};
  depot = {
    "artifacts/2a0fba617ae96fd7bec0e5f0981a2cc395998f08" = pkgs.fetchzip {
      "name" = "artifact-2a0fba617ae96fd7bec0e5f0981a2cc395998f08";
      "sha256" = "161qv38b1ac2zv9y0an3gnwppdx37mw5s57gq81xxlwzh4kj1p1s";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/2a0fba617ae96fd7bec0e5f0981a2cc395998f08#artifact.tar.gz";
    };
    "artifacts/2e8fae88dcadc37883e31246fe7397f4f1039f88" = pkgs.fetchzip {
      "name" = "artifact-2e8fae88dcadc37883e31246fe7397f4f1039f88";
      "sha256" = "1m8drkzrg69qx1hhnxr75wnjapfy7ryrvznihx5bk4imvzg2n44m";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/2e8fae88dcadc37883e31246fe7397f4f1039f88#artifact.tar.gz";
    };
    "artifacts/43eef4d016f011145955de2ba33450dda0536252" = pkgs.fetchzip {
      "name" = "artifact-43eef4d016f011145955de2ba33450dda0536252";
      "sha256" = "1lpdlvy4hgrxl1lmjk58yppc5vfpfr9zsjyqflxvq92dlqsavbrw";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/43eef4d016f011145955de2ba33450dda0536252#artifact.tar.gz";
    };
    "artifacts/75b2da9ed2ec48588460be0f3a8bb489212012e9" = pkgs.fetchzip {
      "name" = "artifact-75b2da9ed2ec48588460be0f3a8bb489212012e9";
      "sha256" = "0f1v96xb7rqciyy6av0snynryg3fhmvllbvbnpd6vkxx4cvpazpc";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/75b2da9ed2ec48588460be0f3a8bb489212012e9#artifact.tar.gz";
    };
    "artifacts/93d795500c7b63f53b10478c17435f32e7a3c443" = pkgs.fetchzip {
      "name" = "artifact-93d795500c7b63f53b10478c17435f32e7a3c443";
      "sha256" = "0wbqihac7yhlwihf91bbmjkizwra122xvxz4zrsgdnyzpbq4zycl";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/93d795500c7b63f53b10478c17435f32e7a3c443#artifact.tar.gz";
    };
    "artifacts/bc7df2a88972dd1ff2685e091585f5c979bfd436" = pkgs.fetchzip {
      "name" = "artifact-bc7df2a88972dd1ff2685e091585f5c979bfd436";
      "sha256" = "05ycfwnw97r1axc36fvg2yjlqb12s7wyhq1awz41x1wy8j36s55j";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/bc7df2a88972dd1ff2685e091585f5c979bfd436#artifact.tar.gz";
    };
    "packages/ArgParse/bylyV" = pkgs.fetchzip {
      "name" = "package-ArgParse";
      "sha256" = "02r4b0zj3cll0s7gpy2g6nya0s0rl7h337dqa9w2glmd3av3a4x8";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/c7e460c6-2fb9-53a9-8c5b-16f535851c63/3102bce13da501c9104df33549f511cd25264d7d#package.tar.gz";
    };
    "packages/Expat_jll/PhUfV" = pkgs.fetchzip {
      "name" = "package-Expat_jll";
      "sha256" = "0lkhkh0067lns35njpc1bqbx6653r99lrjcbgrihlln9a7k9qj1s";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/2e619515-83b5-522b-bb60-26c02a35a201/b3bfd02e98aedfa5cf885665493c5598c350cd2f#package.tar.gz";
    };
    "packages/Gettext_jll/ogctH" = pkgs.fetchzip {
      "name" = "package-Gettext_jll";
      "sha256" = "1k6l48sr7dvfjp96lqabcqnxjjsx4cq7bdvn131gys0n2j954f2y";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/78b55507-aeef-58d4-861c-77aaff3498b1/8c14294a079216000a0bdca5ec5a447f073ddc9d#package.tar.gz";
    };
    "packages/Git/EnxqL" = pkgs.fetchzip {
      "name" = "package-Git";
      "sha256" = "0bznzg360cbvbzzpsdkin4dm2v980sb5pv58gy1bp3j9j8bj38h6";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2/d7bffc3fe097e9589145493c08c41297b457e5d0#package.tar.gz";
    };
    "packages/Git_jll/zXJkl" = pkgs.fetchzip {
      "name" = "package-Git_jll";
      "sha256" = "1bbdkj791f9ciizav7hy40z3zm1c1a824z4l4di80hn3d9pyghw4";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/f8c6e375-362e-5223-8a59-34ff63f689eb/33be385f3432a5a5b7f6965af9592d4407f3167f#package.tar.gz";
    };
    "packages/HTTP/4AvE2" = pkgs.fetchzip {
      "name" = "package-HTTP";
      "sha256" = "1jsyk3mhnwj4h19cxclx26igdqdrw51fd3k1hgav0nm67dy4cxyk";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/cd3eb016-35fb-5094-929b-558a96fad6f3/c6a1fff2fd4b1da29d3dccaffb1e1001244d844e#package.tar.gz";
    };
    "packages/IniFile/R4eEN" = pkgs.fetchzip {
      "name" = "package-IniFile";
      "sha256" = "19cn41w04hikrqdzlxhrgf21rfqhkvj9x1zvwh3yz9hqbf350xs9";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/83e8ac13-25f8-5344-8a64-a9f2b223428f/098e4d2c533924c921f9f9847274f2ad89e018b8#package.tar.gz";
    };
    "packages/JLLWrappers/bkwIo" = pkgs.fetchzip {
      "name" = "package-JLLWrappers";
      "sha256" = "0v7xhsv9z16d657yp47vgc86ggc01i1wigqh3n0d7i1s84z7xa0h";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/692b3bcd-3c85-4b1f-b108-f13ce0eb3210/642a199af8b68253517b80bd3bfd17eb4e84df6e#package.tar.gz";
    };
    "packages/JSON/3rsiS" = pkgs.fetchzip {
      "name" = "package-JSON";
      "sha256" = "1f9k613kbknmp4fgjxvjaw4d5sfbx8a5hmcszmp1w9rqfqngjx9m";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/682c06a0-de6a-54ab-a142-c8b1cf79cde6/81690084b6198a2e1da36fcfda16eeca9f9f24e4#package.tar.gz";
    };
    "packages/Libiconv_jll/tGWLj" = pkgs.fetchzip {
      "name" = "package-Libiconv_jll";
      "sha256" = "0crwl7jl11q4mad6hbmpwfdx9gvr2nr27dj7hzia553wdsjs8kxb";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/94ce4f54-9a6c-5748-9c1c-f9c7231a4531/42b62845d70a619f063a7da093d995ec8e15e778#package.tar.gz";
    };
    "packages/MbedTLS/4YY6E" = pkgs.fetchzip {
      "name" = "package-MbedTLS";
      "sha256" = "0zjzf2r57l24n3k0gcqkvx3izwn5827iv9ak0lqix0aa5967wvfb";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/739be429-bea8-5141-9913-cc70e7f3736d/1c38e51c3d08ef2278062ebceade0e46cefc96fe#package.tar.gz";
    };
    "packages/OpenSSL_jll/fws6q" = pkgs.fetchzip {
      "name" = "package-OpenSSL_jll";
      "sha256" = "1s27s17rls40m3q53xj93fkvvavr7k16ilrhr0hnbr1mvdh5zylc";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/458c3c95-2e84-50aa-8efc-19380b2a3a95/15003dcb7d8db3c6c857fda14891a539a8f2705a#package.tar.gz";
    };
    "packages/Parsers/rIikS" = pkgs.fetchzip {
      "name" = "package-Parsers";
      "sha256" = "1gz3drd5334xrbx2ms33hiifkd0q1in4ywc92xvrkq3xgzdjqjdk";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/69de0a69-1ddd-5017-9359-2bf0b02dc9f0/c8abc88faa3f7a3950832ac5d6e690881590d6dc#package.tar.gz";
    };
    "packages/Preferences/SHSJJ" = pkgs.fetchzip {
      "name" = "package-Preferences";
      "sha256" = "1cail43iqzbi6m9v6981rhz47zf2lcvhs5ds5gdqvc9nx5frghxq";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/21216c6a-2e73-6563-6e65-726566657250/00cfd92944ca9c760982747e9a1d0d5d86ab1e5a#package.tar.gz";
    };
    "packages/TextWrap/DsImh" = pkgs.fetchzip {
      "name" = "package-TextWrap";
      "sha256" = "1nlhi9f9y6nmnjq1z9d60ql39ajpbgc93ji0z7blnddyf48i6zdy";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/b718987f-49a8-5099-9789-dcd902bef87d/9250ef9b01b66667380cf3275b3f7488d0e25faf#package.tar.gz";
    };
    "packages/URIs/o9DQG" = pkgs.fetchzip {
      "name" = "package-URIs";
      "sha256" = "0kp4hg3kknkm2smlcizqfd33l9x4vkahc2714gnbjp39fj285b92";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4/97bbe755a53fe859669cd907f2d96aee8d2c1355#package.tar.gz";
    };
    "packages/XML2_jll/8hNQM" = pkgs.fetchzip {
      "name" = "package-XML2_jll";
      "sha256" = "1g6wf5r5v2qx6cwv05kd9amcsmv65vkajk43m9r1c35jqs9m8fnm";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a/1acf5bdf07aa0907e0a37d3718bb88d4b687b74a#package.tar.gz";
    };
    "registries/General" = pkgs.fetchzip {
      "name" = "registry-General";
      "sha256" = "1dabfdzf8gmw405w5926ybr27fsbvz8m8q5cidpcqhd66gvpqccb";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/registry/23338594-aafe-5451-b93e-139f81909106/71e9e8ceca36d6e97cb61077245a345195b813b0#registry.tar.gz";
    };
  };
}
