{inputs}: {
  default = final: prev: {
    julia2nix = args:
      prev.callPackage ./build {
        inherit inputs;
        pkgs = prev;
      }
      args;
  };
}
