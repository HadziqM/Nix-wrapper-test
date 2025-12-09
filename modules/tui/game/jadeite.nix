{
  fetchzip,
  pkgs,
}:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "jadeite";
  version = "v5.0.1";

  src = fetchzip {
    url = "https://codeberg.org/mkrsym1/jadeite/releases/download/${version}/${version}.zip";
    hash = "sha256-Wxl/9a0K1VOYwwJPKn5lV2y5u77yfPfaUdkCUNfUVfM=";
    stripRoot = false;
  };
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/jadeite
    mkdir -p $out/bin

    cp -v ${src}/* $out/share/jadeite/

    install -m755 $src/block_analytics.sh $out/bin/block_analytics.sh
  '';
}
