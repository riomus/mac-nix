{ inputs }: {
  comma = final: prev: {
    comma = import inputs.comma { inherit (prev) pkgs; };
  };

  apple-silicon = final: prev:
    let inherit (prev.lib) optionalAttrs;
    in optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      pkgs-x86 = import inputs.nixpkgs-unstable {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
    };

  modifications = final: prev:
    let
      inherit (prev.lib) optionalAttrs;

      unstablePkgs = import inputs.nixpkgs-unstable {
        system = prev.stdenv.system;
        config.allowUnfree = true;
      };
    in {
      # Expose ruby_4_0 from nixpkgs-unstable
      ruby_4_0 = unstablePkgs.ruby_4_0;
    } // optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      inherit (final.pkgs-x86) idris2 niv purescript;
    };
}
