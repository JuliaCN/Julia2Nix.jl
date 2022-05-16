{
  pkgs,
  nix2container,
  inputs,
  cell,
}: let
  inherit (inputs.self) packages ;
in
  nix2container.buildImage {
    name = builtins.baseNameOf ./build-package.nix;
    contents = [
      # When we want tools in /, we need to symlink them in order to
      # still have libraries in /nix/store. This differs from
      # dockerTools.buildImage but this allows to avoid habing files
      # both in / and /nix/store.
      (pkgs.symlinkJoin {
        name = "root";
        paths = with pkgs; [pkgs.bashInteractive pkgs.coreutils packages.${pkgs.system}.build-project
                            alejandra nixUnstable nix-prefetch cacert];
      })
    ];
    config = {
      Cmd = ["/bin/julia-project"];
      Env = ["NIX_PATH=nixpkgs=${pkgs.path}" "USER=n2c"];
    };
}
