{ pkgs }:
with pkgs;
stdenv.mkDerivation rec {
    name = "arc-browser-latest";
    src = fetchurl {
        url = "https://releases.arc.net/release/Arc-latest.dmg";
        sha256 = "sha256-02lwBQ4feMYF7hNrvcenTp/w7rabQoRozD6OVOidfZA=";
    };
  nativeBuildInputs = [ undmg unzip ];
  phases = ["unpackPhase" "installPhase"];

  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out
    mkdir -p $out/Applications
    cp -R "Arc.app" "$out/Applications"
    '';
    meta = {
    };
}