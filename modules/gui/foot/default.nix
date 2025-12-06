{ pkgs, symlinkJoin, ... }:
symlinkJoin {
  name = "foot";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [ pkgs.foot ];
  postBuild = ''
    wrapProgram $out/bin/foot \
    --add-flags "-c ${./config.ini}"
  '';
}
