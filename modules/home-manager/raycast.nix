{ pkgs }:
with pkgs;
stdenv.mkDerivation rec {
    name = "raycast-latest";
    src = fetchurl {
        name = "raycast.dmg";
        url = "https://releases.raycast.com/releases/1.70.2/download?build=universal";
        sha256 = "sha256-t0lc59RcOF7umUjyxQll4RZNyboiuMaP8dZ15vcuaAE=";
    };
  nativeBuildInputs = [ undmg unzip ];
  phases = ["unpackPhase" "installPhase"];

  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out
    mkdir -p $out/Applications
    cp -R "Raycast.app" "$out/Applications"
    '';
    meta = {
    };
}