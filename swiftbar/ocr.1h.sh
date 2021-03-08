#!/bin/bash
set -euo pipefail
shopt -s nullglob

# <bitbar.dependencies>bash,tesseract</bitbar.dependencies>

echo ':target:'
echo ---
echo "OCR | bash=$SWIFTBAR_PLUGINS_PATH/../bin/ocr terminal=false shortcut=cmd+shift+1"
