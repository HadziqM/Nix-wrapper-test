{ pkgs, ... }:
pkgs.symlinkJoin {
  name = "starship";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [ pkgs.starship ];
  postBuild = ''
    chmod +x $out/bin/starship
    wrapProgram $out/bin/starship \
    --set STARSHIP_CONFIG ${./config.toml}
  '';
}
