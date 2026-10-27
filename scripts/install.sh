#!/usr/bin/env bash
# Asentaa (tai päivittää) MagicMirror²:n ja tämän repon asetukset Raspberry Pi:lle.
#
# Käyttö:
#   git clone https://github.com/ggashion/ggashion.git ~/ggashion
#   ~/ggashion/scripts/install.sh
#
# Skriptin voi ajaa uudelleen milloin vain: se päivittää MagicMirrorin ja
# moduulit eikä koske config.env-tiedostoon, jos se on jo olemassa.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MM_DIR="${MM_DIR:-$HOME/MagicMirror}"

step() { echo; echo "==> $*"; }

if [ "$(id -u)" -eq 0 ]; then
	echo "Älä aja tätä sudolla, vaan tavallisena käyttäjänä." >&2
	exit 1
fi

step "Järjestelmäpaketit"
sudo apt-get update
sudo apt-get install -y git curl gpiod wlr-randr

step "Node.js"
# MagicMirror vaatii Node.js:n >= 22.22.2 (22.x) tai >= 24
node_ok() {
	command -v node >/dev/null 2>&1 && node -e '
		const [a, b, c] = process.versions.node.split(".").map(Number);
		process.exit(a >= 24 || (a === 22 && (b > 22 || (b === 22 && c >= 2))) ? 0 : 1);
	'
}
if ! node_ok; then
	curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
	sudo apt-get install -y nodejs
fi
node -v

if ! command -v pm2 >/dev/null 2>&1; then
	sudo npm install -g pm2
fi

step "MagicMirror²"
if [ -d "$MM_DIR/.git" ]; then
	git -C "$MM_DIR" pull --ff-only
else
	git clone --depth 1 https://github.com/MagicMirrorOrg/MagicMirror "$MM_DIR"
fi
(cd "$MM_DIR" && npm run install-mm)

step "Lisämoduulit (modules.txt)"
grep -vE '^\s*(#|$)' "$REPO_DIR/modules.txt" | while read -r url; do
	name="$(basename "$url" .git)"
	dir="$MM_DIR/modules/$name"
	if [ -d "$dir/.git" ]; then
		echo "Päivitetään $name"
		git -C "$dir" pull --ff-only
	else
		echo "Asennetaan $name"
		git clone --depth 1 "$url" "$dir"
	fi
	if [ -f "$dir/package.json" ]; then
		(cd "$dir" && npm install --omit=dev --no-audit --no-fund < /dev/null)
	fi
done

step "Asetukset"
if [ ! -f "$REPO_DIR/config/config.env" ]; then
	sed "s|^MIRROR_DIR=.*|MIRROR_DIR=$REPO_DIR|" "$REPO_DIR/config/config.env.example" \
		> "$REPO_DIR/config/config.env"
	echo "Luotiin $REPO_DIR/config/config.env – lisää sinne HSL_APIKEY!"
fi
for f in config.js config.env custom.css; do
	target="$MM_DIR/config/$f"
	# Varmuuskopio, jos kohteessa on oikea tiedosto eikä jo linkki
	if [ -e "$target" ] && [ ! -L "$target" ]; then
		mv "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"
	fi
	ln -sfn "$REPO_DIR/config/$f" "$target"
done

step "Automaattikäynnistys ja näytönsäästäjä"
if command -v raspi-config >/dev/null 2>&1; then
	sudo raspi-config nonint do_boot_behaviour B4 # työpöytä, automaattinen kirjautuminen
	sudo raspi-config nonint do_blanking 1        # ei näytön pimennystä
fi
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/magicmirror.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=MagicMirror
Exec=$REPO_DIR/scripts/start-mm.sh
X-GNOME-Autostart-enabled=true
EOF

step "Valmis!"
cat <<EOF
Seuraavaksi:
  1. Lisää Digitransit API -avain:  nano $REPO_DIR/config/config.env
  2. Vaihda omat pysäkit:            nano $REPO_DIR/config/config.js
  3. Käynnistä Pi uudelleen:         sudo reboot

Hyödyllisiä komentoja:
  pm2 logs MagicMirror      # lokit
  pm2 restart MagicMirror   # uudelleenkäynnistys asetusten muuttamisen jälkeen
EOF
