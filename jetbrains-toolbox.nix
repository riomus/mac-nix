{ pkgs }:
with pkgs;
stdenv.mkDerivation rec {
    name = "jetbrains-toolbox-latest";
    src = fetchurl {
        name = "toolbox.dmg";
        url = "https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.2.3.20090-arm64.dmg";
        sha256 = "sha256-JfAMkCJALhbEqTwwq82DK95gCF1703EDwxVu8l4nJ8o=";
    };
  nativeBuildInputs = [ undmg unzip ];
  phases = ["unpackPhase" "installPhase"];

  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out
    mkdir -p $out/Applications
    cp -R "Jetbrains Toolbox.app" "$out/Applications"
    '';
    meta = {
    };
}