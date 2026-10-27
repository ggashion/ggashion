#!/usr/bin/env bash
# Näytön ohjaus Waylandissa (Raspberry Pi OS, labwc).
# Käyttö: screen.sh on|off
#
# "on" asettaa samalla pystykierron, koska wlr-randr ei aina muista sitä
# näytön sammuttamisen jälkeen.
set -u

OUTPUT="${MM_SCREEN_OUTPUT:-HDMI-A-1}"
TRANSFORM="${MM_SCREEN_TRANSFORM:-90}"

# Kun skripti ajetaan SSH:n kautta, Wayland-ympäristömuuttujat puuttuvat
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
	sock=$(ls "$XDG_RUNTIME_DIR" 2>/dev/null | grep -E '^wayland-[0-9]+$' | head -n1)
	export WAYLAND_DISPLAY="${sock:-wayland-0}"
fi

case "${1:-}" in
	on)  exec wlr-randr --output "$OUTPUT" --on --transform "$TRANSFORM" ;;
	off) exec wlr-randr --output "$OUTPUT" --off ;;
	*)   echo "Käyttö: $0 on|off" >&2; exit 1 ;;
esac
