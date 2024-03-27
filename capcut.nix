{ pkgs }:
with pkgs;
stdenv.mkDerivation rec {
    name = "capcut-latest";
    src = fetchurl {
        name = "capcut.dmg";
        url = "https://lf16-capcut.faceulv.com/obj/capcutpc-packages-us/installer/capcut_capcutpc_0_1.2.6_installer.dmg";
        sha256 = "sha256-81aagiaz7Gh9pB7VcQ+ucEP4JPKa0cnN5Yo2GQwl5UE=";
    };
  nativeBuildInputs = [ undmg unzip ];
  phases = ["unpackPhase" "installPhase"];

  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out
    mkdir -p $out/Applications
    cp -R "CapCut-Downloader.app" "$out/Applications"
    '';
    meta = {
    };
}