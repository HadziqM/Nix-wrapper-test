set -euo pipefail

geometry=$(slurp) || exit 0
[ -z "$geometry" ] && exit 0

raw_text=$(grim -g "$geometry" - | tesseract stdin stdout -l jpn+jpn_vert+eng+fra+deu --psm 6 2>/dev/null)

if [ -z "$raw_text" ]; then
    notify-send -i dialog-warning "OCR Result" "No text recognized."
    exit 0
fi

translated_text=$(trans -b -to eng "$raw_text")

printf '%s %s' "$raw_text" "$translated_text" | wl-copy
notify-send -i edit-copy "Translated & Copied" "$translated_text"
