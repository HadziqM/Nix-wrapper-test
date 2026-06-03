{ pkgs, writeScriptBin, ... }:
let
  vn-fix = writeScriptBin "vn-fix.sh" (builtins.readFile ./vn.sh);
  jadeite = pkgs.callPackage ./jadeite.nix { };

  # from protonup-rs, proton cant be packaged because valve license policy
  # i can make it myself if i didnt need to upload the code to github
  proton-path = "$HOME/.steam/steam/compatibilitytools.d/GE-Proton10-26";
  # TODO: make script to automate making prefix with available fix
  prefix = "$HOME/temp/prefix";
  set-env = ''
    if [ "$PROTONPATH" = "" ]; then PROTONPATH=${proton-path}; fi        
    if [ "$WINEPREFIX" = "" ]; then WINEPREFIX=${prefix}; fi

    export WINEDEBUG="-all"
    export WINEDLLOVERRIDES="d3d11=n;d3d12=n;dxgi=n"
    export WINEPREFIX
    export PROTONPATH

    echo "using prefix $WINEPREFIX"
    echo "using proton $PROTONPATH"
  '';
  mango-config = ''
    export MANGOHUD_CONFIG="font_size=12,preset=3"
  '';
  gamescope-arg = "-w 1920 -h 1080 -f --adaptive-sync";
  gacha-run = writeScriptBin "gacha-run.sh" ''
    ${set-env}
    LINUX_PATH="$1"

    # convert relative to absolute path
    if [ "$(printf '%s' "$LINUX_PATH" | cut -c1)" != "/" ]; then
      LINUX_PATH="$(pwd)/$LINUX_PATH"
    fi

    # wine always treat linux root folder to z: disk
    WIN_PATH="$(printf '%s' "Z:$LINUX_PATH" | sed 's|/|\\|g')"

    printf "using win path '%s'\n" "$WIN_PATH"

    exec ${pkgs.gamemode}/bin/gamemoderun \
         ${pkgs.gamescope}/bin/gamescope ${gamescope-arg} -- \
         ${pkgs.umu-launcher}/bin/umu-run \
         ${jadeite}/share/jadeite/jadeite.exe "$WIN_PATH"
  '';
  game-run = writeScriptBin "game-run.sh" ''
    ${set-env}

    exec ${pkgs.gamemode}/bin/gamemoderun \
         ${pkgs.umu-launcher}/bin/umu-run "$@"
  '';
  game-run-mango = writeScriptBin "game-mango.sh" ''
    ${set-env}
    ${mango-config}
    exec ${pkgs.gamemode}/bin/gamemoderun \
         ${pkgs.gamescope}/bin/gamescope ${gamescope-arg} -- \
         ${pkgs.mangohud}/bin/mangohud \
         ${pkgs.umu-launcher}/bin/umu-run "$@"
  '';

in
pkgs.symlinkJoin {
  name = "game";
  # buildInputs = [ pkgs.makeWrapper ];
  paths = with pkgs; [
    vn-fix
    game-run
    gacha-run
    game-run-mango
    jadeite
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
