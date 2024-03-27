{ pkgs }:
with pkgs;
stdenv.mkDerivation rec {
    name = "sketchybar-app-font-2.0.15";
    src = fetchurl {
      name = "sketchybar-app-font.ttf";
        url = "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.15/sketchybar-app-font.ttf";
        sha256 = "sha256-s1mnoHEozmDNsW0P4z97fupAVElxikia0TYLVHJPAM4=";
    };
  phases = ["installPhase"];

  sourceRoot = ".";
  installPhase = ''
        mkdir -p $out/share/fonts
        cp -R $src $out/share/fonts/sketchybar-app-font.ttf
        ls $out/share/fonts/
    '';
    meta = {
    };
}