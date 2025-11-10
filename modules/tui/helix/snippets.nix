{ pkgs, ... }:
pkgs.symlinkJoin {
  name = "hx-lsp";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [
    pkgs.hx-lsp
  ];
  postBuild = ''
    mkdir -p $out/config/helix/snippets
    cp ${./flutter.json} $out/config/helix/snippets/dart.json

    wrapProgram $out/bin/hx-lsp \
    --set XDG_CONFIG_HOME $out/config
  '';
}
