#!/usr/bin/env bash
# Käynnistää MagicMirrorin pm2:lla. Ajetaan työpöydän automaattikäynnistyksestä,
# jotta MagicMirror saa näytön (Wayland) ympäristömuuttujat.
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MM_DIR="${MM_DIR:-$HOME/MagicMirror}"

# Näytön asetukset config.env:stä (kierto yms.)
if [ -f "$REPO_DIR/config/config.env" ]; then
	set -a
	. "$REPO_DIR/config/config.env"
	set +a
fi

"$REPO_DIR/scripts/screen.sh" on || true

cd "$MM_DIR" || exit 1
pm2 delete MagicMirror >/dev/null 2>&1 || true
pm2 start npm --name MagicMirror -- start
