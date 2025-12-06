{
  pkgs,
  lib,
  callPackage,
  withNixd ? true,
  ...
}:
let
  hx-lsp = callPackage ./snippets.nix { };
  discord-rpc = callPackage ./discord-rpc.nix { };

  servers = [
    "statix"
    "discord-rpc"
  ]
  ++ pkgs.lib.optional withNixd "nixd";

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
    command = "${lib.getExe pkgs.nixfmt-rfc-style}"


    [[language]]
    name = "rust"
    language-servers = ["rust-analyzer", "hx-lsp", "discord-rpc"]

    [language.formatter]
    command = "rustfmt"

    [[language]]
    language-servers = ["dart", "hx-lsp", "discord-rpc"]
    name = "dart"

    [language-server.hx-lsp]
    command = "${hx-lsp}/bin/hx-lsp"

    ${lsp}

    [language-server.rust-analyzer.config.check]
    command = "clippy"

    [language-server.statix]
    command = "${lib.getExe pkgs.statix}"


    [language-server.discord-rpc]
    command = "${lib.getExe discord-rpc}"
  '';
in

pkgs.symlinkJoin {
  name = "helix";
  buildInputs = [ pkgs.makeWrapper ];
  paths = [
    pkgs.helix
    hx-lsp
    discord-rpc
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
