{
  pkgs,
  symlinkJoin,
  callPackage,
  writeShellApplication,
}:
let
  yt = callPackage ./yt-dlp.nix { };

  downloads = writeShellApplication {
    name = "download-music";

    runtimeInputs = [ yt ];

    text = ''
      yt-dlp \
        -x --audio-format mp3 \
        --add-metadata --embed-thumbnail \
        -o "$HOME/Music/%(title)s.%(ext)s" \
        -a ${./list.txt}
    '';
  };
in
symlinkJoin {
  name = "music";
  paths = with pkgs; [
    yt
    ffmpeg
    termusic
    downloads
    # mpd
    # mpd-discord-rpc
    # mpd-notification
    # ncmpcpp
  ];
}
