{
  pkgs,
  inputs,
  symlinkJoin,
  replaceVars,
  system,
  ...
}:
let
  conf = replaceVars ./config.kdl {
    pantheon-polkit = builtins.toString pkgs.pantheon.pantheon-agent-polkit;
  };
in
symlinkJoin {
  name = "niri";
  buildInputs = [ pkgs.makeWrapper ];
  paths = with pkgs; [
    niri
    inputs.noctalia.packages.${system}.default
    xwayland-satellite
    pantheon.pantheon-agent-polkit
    playerctl
    brightnessctl
    wl-clipboard
    wl-clip-persist
    cliphist
    libnotify
  ];
  postBuild = ''
    wrapProgram $out/bin/niri \
    --append-flags -c ${conf}
  '';
}
