{ inputs, cell}:
let
  inherit (cell.library) n2c;
  inherit (cell) packages;
  inherit (inputs) nixpkgs;
  inherit (inputs.cells-lab._writers) library;
in
{
  podman-image-build-package = library.writeShellApplication {
    name = "build-package";
    runtimeInputs = [nixpkgs.podman];
    text = ''
      ${packages.image-build-package.copyToPodman}/bin/copy-to-podman
      podman run -it ${packages.image-build-package.imageName}:${packages.image-build-package.imageTag} julia --version
    '';
  };
}
