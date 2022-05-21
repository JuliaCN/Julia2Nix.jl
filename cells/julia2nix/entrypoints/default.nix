{
  inputs,
  cell,
}: let
  inherit (inputs.cells-lab._writers.library) writeShellApplication;
  inherit (inputs) self nixpkgs std;
in {
  mkdoc = let
    org-roam-book = inputs.org-roam-book-template.packages.${nixpkgs.system}.default.override {
      org = "${(std.incl self [
        (self + /docs/src)
      ])}/docs/src";
    };
  in
    writeShellApplication {
      name = "mkdoc";
      runtimeInputs = [nixpkgs.hugo];
      text = ''
        rsync -avzh ${org-roam-book}/* docs/publish
        cd docs/publish && cp ../config.toml .
        hugo "$@"
        cp -rf --no-preserve=mode,ownership public/posts/index.html ./public/
      '';
    };
}
