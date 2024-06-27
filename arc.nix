{ pkgs }:
with pkgs;
stdenv.mkDerivation rec {
    name = "arc-browser-latest";
    src = fetchurl {
        url = "https://releases.arc.net/release/Arc-latest.dmg";
        sha256 = "sha256-XrFDYzRUGCSyM8E+zHK/OZMKWYI9kCxUQ2TI98htPWk=";
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