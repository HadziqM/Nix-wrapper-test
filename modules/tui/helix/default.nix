{ pkgs, ... }:
let
  hx-lsp = pkgs.callPackage ./snippets.nix;
  languages = pkgs.writeText "languages.toml" ''
        
    [[language]]
    auto-format = true
    language-servers = ["nixd", "statix"]
    name = "nix"

    [language.formatter]
    command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt"

    [[language]]
    language-servers = ["sqls"]
    name = "sql"

    [[language]]
    name = "rust"

    [language.formatter]
    command = "rustfmt"

    [[language]]
    language-servers = ["svelteserver", "tailwind"]
    name = "svelte"

    [[language]]
    language-servers = ["dart", "hx-lsp"]
    name = "dart"

    [language-server.hx-lsp]
    command = "${hx-lsp}/bin/hx-lsp"

    [language-server.nixd]
    command = "${pkgs.nixd}/bin/nixd"

    [language-server.rust-analyzer.config.check]
    command = "clippy"

    [language-server.sqls]
    command = "${pkgs.sqlint}/bin/sqlint"

    [language-server.statix]
    command = "${pkgs.statix}/bin/statix"

    [language-server.tailwind]
    args = ["--stdio"]
    command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server"
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
    --set $XDG_CONFIG_HOME $out/config
  '';
}
