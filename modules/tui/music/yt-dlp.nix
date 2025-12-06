{
  fetchurl,
  pkgs,
}:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "yt-dlp";
  version = "2025.11.12";

  src = fetchurl {
    url = "https://github.com/yt-dlp/yt-dlp/releases/download/${version}/yt-dlp_linux";
    hash = "sha256-G0jK99XveCanJZX7m8sZTH7jqHfqXhDSa1K8mWdXdhs=";
  };
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 $src $out/bin/yt-dlp
  '';
}
