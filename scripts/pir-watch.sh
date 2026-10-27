#!/usr/bin/env bash
# Kuuntelee liiketunnistimen GPIO-pinniä ja tulostaa rivin jokaisesta muutoksesta.
# MMM-Universal-Pir käynnistää tämän ja tulkitsee jokaisen rivin liikkeeksi.
#
# Seurataan molempia reunoja (nouseva ja laskeva), jotta sammutusajastin
# lasketaan vasta siitä, kun liike loppuu.
set -u

PIN="${MM_PIR_GPIO:-23}"
CHIP="${MM_PIR_CHIP:-gpiochip0}"

# gpiomonista on kaksi versiota eri syntaksilla: v1 (Bookworm) ja v2 (Trixie)
ver=$(gpiomon -v 2>/dev/null | grep -oE 'v[0-9]+' | head -n1)

# stdbuf: tulostetaan rivi kerrallaan, muuten tapahtumat jäävät puskuriin
if [ "$ver" = "v1" ]; then
	exec stdbuf -oL gpiomon "$CHIP" "$PIN"
else
	exec stdbuf -oL gpiomon -c "$CHIP" "$PIN"
fi
