{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:
let
  runtimeLibs = with pkgs; [
    qt6.qtbase
    libX11
    libxcb
    libXext
    libxkbcommon
    libglvnd
    stdenv.cc.cc.lib
  ];
in

stdenv.mkDerivation {
  pname = "cheat-engine";
  version = "7.7.1";

  src = fetchzip {
    url = "https://cheatengine.org/download/CheatEngineLinux771.zip";
    hash = "sha256-J1eFAskhZcPmxHyKAgRGI5bLqwl3Z5Qrf+DFVp+Z0LM=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  dontWrapQtApps = true;

  buildInputs = runtimeLibs;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/cheat-engine

    cp -r . $out/lib/cheat-engine/

    # Ensure main executables are runnable
    chmod +x $out/lib/cheat-engine/cheatengine-x86_64
    chmod +x $out/lib/cheat-engine/tutorial-x86_64
    chmod +x $out/lib/cheat-engine/gtutorial-x86_64

    makeWrapper $out/lib/cheat-engine/cheatengine-x86_64 $out/bin/cheatengine \
      --chdir "$out/lib/cheat-engine" \
      --prefix LD_LIBRARY_PATH : "$out/lib/cheat-engine:${lib.makeLibraryPath runtimeLibs}"
      
    runHook postInstall
  '';

  meta = with lib; {
    description = "Cheat Engine for Linux";
    homepage = "https://cheatengine.org";
    license = licenses.unfree;
    mainProgram = "cheatengine";
    platforms = [ "x86_64-linux" ];
  };
}
