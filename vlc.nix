{ pkgs }:
with pkgs;
stdenv.mkDerivation rec {
    name = "vlc-latest";
    src = fetchurl {
        name = "vlc.dmg";
        url = "https://ftp.sh.cvut.cz/videolan/vlc/3.0.20/macosx/vlc-3.0.20-arm64.dmg";
        sha256 = "sha256-XV8O5S2BmCpiL0AhkopktHBalVRJniDDPQusIlkLEY4=";
    };
  nativeBuildInputs = [ undmg unzip ];
  phases = ["unpackPhase" "installPhase"];

  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out
    mkdir -p $out/Applications
    cp -R "VLC.app" "$out/Applications"
    '';
    meta = {
    };
}