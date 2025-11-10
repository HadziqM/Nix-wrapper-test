{
  pkgs,
  withNixd ? true,
  ...
}:
let
  hx-lsp = pkgs.callPackage ./snippets.nix { };

  servers = [ "statix" ] ++ pkgs.lib.optional withNixd "nixd";

  lsp =
    if withNixd then
      ''
        [language-server.nixd]
        command = "${pkgs.nixd}/bin/nixd"
      ''
    else
      "";
  languages = pkgs.writeText "languages.toml" ''
        
    [[language]]
    auto-format = true
    language-servers = [${pkgs.lib.concatStringsSep ", " (map (s: "\"${s}\"") servers)}]
    name = "nix"

    [language.formatter]
    command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt"


    [[language]]
    name = "rust"

    [language.formatter]
    command = "rustfmt"

    [[language]]
    language-servers = ["dart", "hx-lsp"]
    name = "dart"

    [language-server.hx-lsp]
    command = "${hx-lsp}/bin/hx-lsp"

    ${lsp}

    [language-server.rust-analyzer.config.check]
    command = "clippy"

    [language-server.statix]
    command = "${pkgs.statix}/bin/statix"

  '';
in

pkgs.symlinkJoin {
  name = "helix";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [
    pkgs.helix
    hx-lsp
  ];
  postBuild = ''
    mkdir -p $out/config/helix/themes
    cp ${./config.toml} $out/config/helix/config.toml
    cp ${languages} $out/config/helix/languages.toml
    cp ${./ignores} $out/config/helix/ignore
    cp ${./themes.toml} $out/config/helix/themes/mocha_transparent.toml

    wrapProgram $out/bin/hx \
    --set XDG_CONFIG_HOME $out/config
  '';
}
