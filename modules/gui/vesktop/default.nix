{ pkgs, ... }:
pkgs.symlinkJoin {
  name = "vesktop";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [ pkgs.vesktop ];
  postBuild = ''
    mkdir -p $out/config/vesktop/configs
    mkdir -p $out/config/vesktop/themes

    cp ${./config.json} $out/config/vesktop/settings.json
    cp ${./theme.json} $out/config/vesktop/settings/settings.json
    cp ${./vesktop.css} $out/config/vesktop/themes/selected.css

    wrapProgram $out/bin/vesktop \
    --set XDG_CONFIG_HOME $out/config
  '';
}
