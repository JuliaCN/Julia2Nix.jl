{inputs}: {
  default = final: prev: {
    rust-final = final.rust-bin.stable.latest.default.override {
      extensions = ["rust-src"];
    };
  };
}
