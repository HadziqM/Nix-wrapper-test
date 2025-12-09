{ pkgs, writeScriptBin, ... }:
let
  vn-fix = writeScriptBin "vn-fix.sh" (builtins.readFile ./vn.sh);
  jadeite = pkgs.callPackage ./jadeite.nix { };

  # from protonup-rs, proton cant be declarative because valve license policy
  # i can make it myself if i didnt upload the code to github
  proton-path = "$HOME/.steam/steam/compatibilitytools.d/GE-Proton10-26";
  # TODO: make script to automate making prefix with available fix
  prefix = "$HOME/temp/prefix";
  set-env = ''
    if [ "$PROTONPATH" = "" ]; then PROTONPATH=${proton-path}; fi        
    if [ "$WINEPREFIX" = "" ]; then WINEPREFIX=${prefix}; fi

    export WINEDEBUG="-all"
    export WINEPREFIX
    export PROTONPATH

    echo "using prefix $WINEPREFIX"
    echo "using proton $PROTONPATH"
  '';

  game-run = writeScriptBin "game-run.sh" ''
    ${set-env}

    exec ${pkgs.gamemode}/bin/gamemoderun \
         ${pkgs.gamescope}/bin/gamescope -- \
         ${pkgs.umu-launcher}/bin/umu-run "$@"
  '';

  gacha-run = writeScriptBin "gacha-run.sh" ''
    ${set-env}
    LINUX_PATH="$1"

    # convert relative to absolute path
    if [ "$(printf '%s' "$LINUX_PATH" | cut -c1)" != "/" ]; then
      LINUX_PATH="$(pwd)/$LINUX_PATH"
    fi

    # wine always treat linux abs path with z:
    WIN_PATH="$(printf '%s' "Z:$LINUX_PATH" | sed 's|/|\\|g')"

    echo "using win path $WIN_PATH"

    exec ${pkgs.gamemode}/bin/gamemoderun \
       ${pkgs.gamescope}/bin/gamescope -- \
       ${pkgs.umu-launcher}/bin/umu-run \
       ${jadeite}/share/jadeite/jadeite.exe "$WIN_PATH"
  '';
in
pkgs.symlinkJoin {
  name = "game";
  # buildInputs = [ pkgs.makeWrapper ];
  paths = with pkgs; [
    vn-fix
    game-run
    gacha-run
    umu-launcher
    wineWowPackages.stable
    protonup-rs
    gamescope
    # mangohud
    gamemode
    lsfg-vk
    lsfg-vk-ui
    winetricks
    # protontricks
  ];
}
