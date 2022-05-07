{pkgs ? import <nixpkgs> {}}: {
  meta = {"pkgServer" = "https://pkg.julialang.org";};
  depot = {
    "artifacts/43eef4d016f011145955de2ba33450dda0536252" = pkgs.fetchzip {
      "sha256" = "1lpdlvy4hgrxl1lmjk58yppc5vfpfr9zsjyqflxvq92dlqsavbrw";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/43eef4d016f011145955de2ba33450dda0536252#artifact.tar.gz";
    };
    "artifacts/473dc2ed3d46252c87733b7fdca3da64c6f9f917" = pkgs.fetchzip {
      "sha256" = "1vnxgwnjgi3j0khppv5frq3vvw5wxvib5680xlvhcd5dar36hby2";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/473dc2ed3d46252c87733b7fdca3da64c6f9f917#artifact.tar.gz";
    };
    "artifacts/93d795500c7b63f53b10478c17435f32e7a3c443" = pkgs.fetchzip {
      "sha256" = "0wbqihac7yhlwihf91bbmjkizwra122xvxz4zrsgdnyzpbq4zycl";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/93d795500c7b63f53b10478c17435f32e7a3c443#artifact.tar.gz";
    };
    "artifacts/c91b35452c8fa91e8ac43993a2bc8fb4f78476bb" = pkgs.fetchzip {
      "sha256" = "01blvcx6dmq7ywzwnbhbhpwqqydknwdz2av5b2fmipz6367ad4hl";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/c91b35452c8fa91e8ac43993a2bc8fb4f78476bb#artifact.tar.gz";
    };
    "artifacts/e6e5f41352118bbeb44677765ebccab8c151c72a" = pkgs.fetchzip {
      "sha256" = "025j774gnawmg50j9vizkw3vy857qjhscjd29iqc45lhx9ni76d7";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/e6e5f41352118bbeb44677765ebccab8c151c72a#artifact.tar.gz";
    };
    "artifacts/f371e7030764d7d3b86474ca985d35b87195302b" = pkgs.fetchzip {
      "sha256" = "0g98ll698h6g6z5ldibh6ql8w7sq6qg90favjddc38dv7bwqil8d";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/artifact/f371e7030764d7d3b86474ca985d35b87195302b#artifact.tar.gz";
    };
    "packages/Expat_jll/InUJD" = pkgs.fetchzip {
      "sha256" = "01g1wiyl6s9558s9im2ird0q18cvq98mvhn6ipjh9kb1v73khzd2";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/2e619515-83b5-522b-bb60-26c02a35a201/1402e52fcda25064f51c77a9655ce8680b76acf0#package.tar.gz";
    };
    "packages/Gettext_jll/ogctH" = pkgs.fetchzip {
      "sha256" = "1k6l48sr7dvfjp96lqabcqnxjjsx4cq7bdvn131gys0n2j954f2y";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/78b55507-aeef-58d4-861c-77aaff3498b1/8c14294a079216000a0bdca5ec5a447f073ddc9d#package.tar.gz";
    };
    "packages/Git/EnxqL" = pkgs.fetchzip {
      "sha256" = "0bznzg360cbvbzzpsdkin4dm2v980sb5pv58gy1bp3j9j8bj38h6";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2/d7bffc3fe097e9589145493c08c41297b457e5d0#package.tar.gz";
    };
    "packages/Git_jll/zXJkl" = pkgs.fetchzip {
      "sha256" = "1bbdkj791f9ciizav7hy40z3zm1c1a824z4l4di80hn3d9pyghw4";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/f8c6e375-362e-5223-8a59-34ff63f689eb/33be385f3432a5a5b7f6965af9592d4407f3167f#package.tar.gz";
    };
    "packages/JLLWrappers/bkwIo" = pkgs.fetchzip {
      "sha256" = "0v7xhsv9z16d657yp47vgc86ggc01i1wigqh3n0d7i1s84z7xa0h";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/692b3bcd-3c85-4b1f-b108-f13ce0eb3210/642a199af8b68253517b80bd3bfd17eb4e84df6e#package.tar.gz";
    };
    "packages/Libiconv_jll/bLsPg" = pkgs.fetchzip {
      "sha256" = "07xd1lbp8ldavxpik9h40wx80mfaf0isz9jza4g7xgfcbyfqh1d8";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/94ce4f54-9a6c-5748-9c1c-f9c7231a4531/8e924324b2e9275a51407a4e06deb3455b1e359f#package.tar.gz";
    };
    "packages/OpenSSL_jll/l2Av2" = pkgs.fetchzip {
      "sha256" = "15317wll2b1nks8ayg633ar8d9n3sil2nn4rrx165jdgsf2zndij";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/458c3c95-2e84-50aa-8efc-19380b2a3a95/71bbbc616a1d710879f5a1021bcba65ffba6ce58#package.tar.gz";
    };
    "packages/Preferences/BbvxU" = pkgs.fetchzip {
      "sha256" = "010bn42gqj81j2bi7zswfvh0g74g2pj28iqhncnpnhfg9znsp0li";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/21216c6a-2e73-6563-6e65-726566657250/ea79e4c9077208cd3bc5d29631a26bc0cff78902#package.tar.gz";
    };
    "packages/XML2_jll/Slt3Q" = pkgs.fetchzip {
      "sha256" = "18skv7nkihlxs0gk01llg6nq08fnwk98li9rl2vx1azc2r6x1jwf";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/package/02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a/afd2b541e8fd425cd3b7aa55932a257035ab4a70#package.tar.gz";
    };
    "registries/General" = pkgs.fetchzip {
      "sha256" = "0bn71b7rwl41sangp0jaxysx9mxpf1sn9z3cyvqp394m2wgy95h1";
      "stripRoot" = false;
      "url" = "https://pkg.julialang.org/registry/23338594-aafe-5451-b93e-139f81909106/ed5432d347915a94c7b6eb93848e2eeb55cacf4b#registry.tar.gz";
    };
    "registries/JuliaRegistry" = builtins.fetchGit {
      "rev" = "0151ec459b6cd42b89f89d50ed361399fb027464";
      "url" = "https://github.com/colinxs/JuliaRegistry.git";
    };
    "registries/LyceumRegistry" = builtins.fetchGit {
      "rev" = "4235f83dadc2df94b2a5190f4cf5d2f104eccffd";
      "url" = "ssh://git@github.com/Lyceum/LyceumRegistry.git";
    };
  };
}
