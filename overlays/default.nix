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

      # mise from unstable: 25.05 stable pins 2025.5.3, whose aqua-registry
      # mirror endpoint 400s and whose gpg key handling is broken. Unstable
      # ships a recent mise that fetches the registry correctly.
      mise = unstablePkgs.mise;
    } // optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      inherit (final.pkgs-x86) idris2 niv purescript;
    };
}
