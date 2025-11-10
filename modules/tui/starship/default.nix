{ pkgs, ... }:
pkgs.symlinkJoin {
  name = "starship";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [ pkgs.starship ];
  postBuild = ''
    wrapProgram $out/bin/starship \
    --set STARSHIP_CONFIG ${./config.toml}
  '';
}
