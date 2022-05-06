{inputs}: {
  default = final: prev: {
    julia2nix = prev.callPackage ./. {julia = prev.julia_17-bin;};
  };
}
