#!/usr/bin/env bash
# Rasterises the branding SVGs to the 1024px PNGs that flutter_launcher_icons and
# flutter_native_splash consume. The SVGs in assets/branding are the source of
# truth; every PNG in the repo is generated, so never hand-edit one.
#
#   tool/render_branding.sh          # regenerate the PNGs
#   dart run flutter_launcher_icons  # then rebuild the platform icon sets
#   dart run flutter_native_splash:create
set -euo pipefail

cd "$(dirname "$0")/.."
out="assets/branding"

chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
if [[ ! -x "$chrome" ]]; then
  chrome="$(command -v chromium || command -v google-chrome || true)"
fi
if [[ -z "$chrome" || ! -x "$chrome" ]]; then
  echo "Need Chrome to rasterise. Set CHROME=/path/to/chrome and re-run." >&2
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# $1 svg basename (no extension)  $2 png basename  $3 background (hex or "transparent")
render() {
  local src="$1" dst="$2" bg="$3"
  cat > "$tmp/page.html" <<HTML
<!doctype html><meta charset="utf-8">
<style>html,body{margin:0;padding:0;background:transparent}
img{display:block;width:1024px;height:1024px}</style>
<img src="$src.svg">
HTML
  cp "$out/$src.svg" "$tmp/"
  local flags=(--headless --disable-gpu --hide-scrollbars --window-size=1024,1024)
  [[ "$bg" == "transparent" ]] && flags+=(--default-background-color=00000000)
  "$chrome" "${flags[@]}" --screenshot="$out/$dst.png" "$tmp/page.html" >/dev/null 2>&1
  echo "  $out/$dst.png"
}

echo "Rendering branding PNGs at 1024x1024:"
render icon_full       icon_1024            opaque
render logo            logo_1024            opaque
render icon_foreground icon_foreground_1024 transparent
render icon_background icon_background_1024 opaque
render icon_monochrome icon_monochrome_1024 transparent
echo "Done. Now run: dart run flutter_launcher_icons && dart run flutter_native_splash:create"
