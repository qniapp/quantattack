#!/usr/bin/env bash
# Export the release carts (build them first with `rake build:release`) with PICO-8:
#   build/v<version>_export/web/index.html + quantattack_v<version>_release.js  (the GitHub Pages site)
#   build/v<version>_export/bin/            (Windows, macOS, Linux and Raspberry Pi binaries)
# No .p8.png carts: the carts load each other as quantattack_<cart>.p8, which PNG carts cannot satisfy.
# PICO-8 runs headless and muted in a throwaway home, so no window opens and saved data stays untouched.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
pico8=${PICO8:-pico8}
version=$(<data/version.txt)
mapfile -t carts < data/cartridges.txt
release_dir="$PWD/build/v${version}_release"
export_dir="$PWD/build/v${version}_export"
# PICO-8 runs in release_dir; export paths are relative to it.
out="../v${version}_export"
basename="quantattack_v${version}_release"

for cart in "${carts[@]}"; do
  [[ -f "$release_dir/quantattack_${cart}.p8" ]] || { echo "Missing $release_dir/quantattack_${cart}.p8: run rake build:release first." >&2; exit 1; }
done

home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT
mkdir -p "$home/plates"
cp plates/crtplate.html "$home/plates/"
rm -rf "$export_dir"
mkdir -p "$export_dir/web" "$export_dir/bin"

run_pico8() {
  (cd "$release_dir" && SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy "$pico8" -home "$home" "$@")
}

# title is the entry cart; the others are loaded by name with load().
others=()
for cart in "${carts[@]}"; do
  [[ "$cart" == title ]] || others+=("quantattack_${cart}.p8")
done
# Icon: 2x2 sprites from sprite 46 on color 14.
icon="-i 46 -s 2 -c 14"

run_pico8 quantattack_title.p8 -export "$out/web/$basename.html ${others[*]} $icon -p crtplate"
mv "$export_dir/web/$basename.html" "$export_dir/web/index.html"

run_pico8 quantattack_title.p8 -export "$out/bin/$basename.bin ${others[*]} $icon"
[[ -f "$export_dir/web/index.html" && -d "$export_dir/bin/$basename.bin" ]] || { echo 'Export failed' >&2; exit 1; }

ls "$export_dir"/*
