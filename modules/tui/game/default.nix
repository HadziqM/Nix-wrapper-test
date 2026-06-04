{ pkgs, writeScriptBin, ... }:
let
  jadeite = pkgs.callPackage ./jadeite.nix { };

  set-proton-path = ''

    # ----------------------------
    # Proton auto-detection
    # ----------------------------
    if [ "$PROTONPATH" = "" ]; then

      STEAM_DIR="$HOME/.steam/steam/compatibilitytools.d"
      LUTRIS_DIR="$HOME/.local/share/lutris/runners/proton"

      find_latest_proton() {
        local candidates=""

        # Steam GE-Proton
        if [ -d "$STEAM_DIR" ]; then
          candidates="$candidates
          $(find "$STEAM_DIR" -maxdepth 1 -type d -name "GE-Proton*" 2>/dev/null)"
        fi

        # Lutris Proton
        if [ -d "$LUTRIS_DIR" ]; then
          candidates="$candidates
          $(find "$LUTRIS_DIR" -maxdepth 1 -type d 2>/dev/null)"
        fi

        echo "$candidates" \
          | grep -v '^$' \
          | sort -V \
          | tail -n 1
      }

      PROTONPATH="$(find_latest_proton)"

      if [ -z "$PROTONPATH" ] || [ ! -d "$PROTONPATH" ]; then
        echo "No Proton installation found!" >&2
        echo "Make sure you have steam or lutris"
        echo "Run game-init.sh to install GE proton and VNs fixes"
        exit 1
      fi      
      
    fi
  '';

  vn-fix = writeScriptBin "vn-fix.sh" (builtins.readFile ./vn.sh);
  prefix = "$HOME/temp/prefix";
  game-init = writeScriptBin "game-init.sh" ''
    if [ "$WINEPREFIX" = "" ]; then WINEPREFIX=${prefix}; fi
    export WINEPREFIX
    echo "$WINEPREFIX"
    ${pkgs.protonup-rs}/bin/protonup-rs -q
    # ${vn-fix}/bin/vn-fix.sh
    vn-fix.sh lavfilters mciqtz32 mf quartz2 quartz_dx wmp11 xaudio29
  '';

  # TODO: make script to automate making prefix with available fix
  set-env = ''
    if [ "$WINEPREFIX" = "" ]; then WINEPREFIX=${prefix}; fi
    ${set-proton-path}

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
    game-init
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
