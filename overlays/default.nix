{ inputs }:
{
  # Overlays to add various packages into package set
  comma = final: prev: {
    comma = import inputs.comma { inherit (prev) pkgs; };
  };

  # Overlay useful on Macs with Apple Silicon
  apple-silicon = final: prev:
    let
      inherit (prev.lib) optionalAttrs;
    in
    optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      # Add access to x86 packages system is running Apple Silicon
      pkgs-x86 = import inputs.nixpkgs-unstable {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
    };

  modifications = final: prev:
    let
      inherit (prev.lib) optionalAttrs;
    in
    optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      inherit (final.pkgs-x86)
        idris2
        niv
        purescript;
    };
}
