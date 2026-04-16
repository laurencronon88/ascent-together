#!/usr/bin/env bash
# ============================================================
# Ascent Together 2026 — Asset Download Script
# Run once to make this package fully self-contained / offline
#
# Usage:
#   chmod +x download-assets.sh
#   ./download-assets.sh
#
# Requires: curl (macOS/Linux built-in) or wget
# ============================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/assets"
FONTS_DIR="$SCRIPT_DIR/fonts"

echo ""
echo "  Ascent Together 2026 — Downloading Assets"
echo "  =========================================="
echo ""

# ── Helper ────────────────────────────────────────────────────
download() {
  local url="$1"
  local dest="$2"
  if [ -f "$dest" ]; then
    echo "  ✓ Already exists: $(basename $dest)"
    return
  fi
  echo "  ↓ Downloading: $(basename $dest)"
  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$dest"
  else
    echo "  ✗ ERROR: neither curl nor wget found. Install one and re-run."
    exit 1
  fi
  echo "  ✓ Saved: $dest"
}

# ── Images ────────────────────────────────────────────────────
echo "  [1/6] Harrah's Cherokee — hero photo"
download \
  "https://static.wixstatic.com/media/55c2eb_f7f6b098b97d4ad9b3c3848ec9554709~mv2.jpg/v1/fill/w_1200,h_800,al_c,q_85,enc_avif,quality_auto/55c2eb_f7f6b098b97d4ad9b3c3848ec9554709~mv2.jpg" \
  "$ASSETS_DIR/harrahs-hero.jpg"

echo "  [2/6] Convention lockup PNG"
download \
  "https://static.wixstatic.com/media/cb42fa_3dce29713345475d8e57133e76750fef~mv2.png/v1/fill/w_900,h_930,al_c,q_90,enc_avif,quality_auto/AH-1001%202026%20Ascent%20Convention_Branding_Lockup-DarkBG.png" \
  "$ASSETS_DIR/convention-lockup.png"

echo "  [3/6] Harrah's resort logo (white)"
download \
  "https://static.wixstatic.com/media/55c2eb_07f7de84acd64e3096038f974ca599eb~mv2.png/v1/fill/w_172,h_94,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/Harrahs-Cherokee-Casino-Resort-Star-logo-2016---all-white.png" \
  "$ASSETS_DIR/harrahs-logo.png"

echo "  [4/6] Speaker photo — Greg Creed"
download \
  "https://static.wixstatic.com/media/55c2eb_e906fe1eeb1643dda512d497d325082a~mv2.jpg/v1/crop/x_1688,y_0,w_2684,h_3578/fill/w_600,h_800,al_c,q_80,enc_avif,quality_auto/Creed%20Headshot.jpg" \
  "$ASSETS_DIR/speaker-creed.jpg"

echo "  [5/6] Speaker photo — Patrick Noone"
download \
  "https://static.wixstatic.com/media/55c2eb_b180d4ed5148491980fbad6e8bf07e06~mv2.jpg/v1/crop/x_10,y_52,w_231,h_294/fill/w_600,h_763,al_c,q_80,enc_avif,quality_auto/PNoone.jpg" \
  "$ASSETS_DIR/speaker-noone.jpg"

# ── Fonts ─────────────────────────────────────────────────────
echo "  [6/6] Google Fonts — self-hosting"
FONT_CSS_URL="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Barlow+Condensed:ital,wght@0,300;0,400;0,600;0,700;0,800;0,900;1,700&family=Barlow:ital,wght@0,300;0,400;0,500;1,300&display=swap"
FONT_CSS_TMP="$FONTS_DIR/_google-raw.css"
FONT_CSS_OUT="$FONTS_DIR/google-fonts.css"

# Fetch CSS pretending to be a modern browser (so we get woff2)
if command -v curl &>/dev/null; then
  curl -fsSL -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    "$FONT_CSS_URL" -o "$FONT_CSS_TMP"
else
  wget -q --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    "$FONT_CSS_URL" -O "$FONT_CSS_TMP"
fi

# Extract all woff2 URLs and download them
echo "  ↓ Downloading font files..."
grep -oP 'https://[^)]+\.woff2' "$FONT_CSS_TMP" | sort -u | while read -r font_url; do
  font_file=$(echo "$font_url" | grep -oP '[^/]+$' | sed 's/[?&].*//')
  font_name=$(echo "$font_url" | grep -oP '(?<=family=)[^&]+' | head -1 || echo "$font_file")
  dest="$FONTS_DIR/$font_file"
  if [ ! -f "$dest" ]; then
    echo "     font: $font_file"
    if command -v curl &>/dev/null; then
      curl -fsSL "$font_url" -o "$dest"
    else
      wget -q "$font_url" -O "$dest"
    fi
  fi
done

# Rewrite CSS to use local paths
if command -v python3 &>/dev/null; then
  python3 - <<'PYEOF'
import re, os
fonts_dir = os.path.join(os.path.dirname(os.path.abspath("$FONT_CSS_TMP")), "fonts")
with open("$FONT_CSS_TMP") as f:
    css = f.read()
# Replace each woff2 URL with local relative path
def local_path(m):
    url = m.group(0)
    fname = url.split('/')[-1].split('?')[0]
    return f"url('{fname}')"
css = re.sub(r"url\('https://[^']+\.woff2[^']*'\)", local_path, css)
with open("$FONT_CSS_OUT") as f:
    f.write("/* Ascent Together 2026 — Self-hosted Google Fonts */\n")
with open("$FONT_CSS_OUT", 'w') as f:
    f.write("/* Ascent Together 2026 — Self-hosted fonts (auto-generated) */\n\n" + css)
print("  ✓ fonts/google-fonts.css rewritten with local paths")
PYEOF
fi

rm -f "$FONT_CSS_TMP"
echo "  ✓ Fonts complete"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "  =============================================="
echo "  All assets downloaded. Package is now fully"
echo "  self-contained. Open index.html in a browser"
echo "  or deploy the folder to any static host."
echo "  =============================================="
echo ""
