{ pkgs, lib, ... }:
let
  tesseractCustom = pkgs.tesseract.override {
    enableLanguages = [
      "eng"
      "fra"
      "deu"
      "spa"
      "ita"
      "por"
      "rus"
      "jpn"
      "jpn_vert"
    ]; # Expand languages as needed
  };
in
pkgs.writeShellApplication {
  name = "ocr-region";
  meta.platforms = lib.platforms.linux;
  runtimeInputs = with pkgs; [
    coreutils
    grim
    libnotify
    slurp
    tesseractCustom
    translate-shell # Added for auto-detection & translation
    wl-clipboard
  ];
  inheritPath = false;
  text = builtins.readFile ./ocr-region.sh;
}
