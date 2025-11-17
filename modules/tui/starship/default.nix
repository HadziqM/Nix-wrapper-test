{ pkgs, ... }:
let
  empty = pkgs.writeText "starship.toml" "";
in
pkgs.symlinkJoin {
  name = "starship";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [ pkgs.starship ];
  postBuild = ''
    wrapProgram $out/bin/starship \
    --set STARSHIP_CONFIG ${./config.toml}
  '';
}
