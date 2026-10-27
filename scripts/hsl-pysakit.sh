#!/usr/bin/env bash
# Muuttaa HSL-pysäkkikoodit (esim. H3486) tunnuksiksi, joita mm-hsl-timetable tarvitsee.
# Tulostaa rivit, jotka voi liittää suoraan config.js:n stops-listaan.
#
# Käyttö: hsl-pysakit.sh H3486 H3529 H4534
#
# Vaatii HSL_APIKEY-arvon tiedostossa config/config.env.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
API_URL="https://api.digitransit.fi/routing/v2/hsl/gtfs/v1"

if [ $# -eq 0 ]; then
	echo "Käyttö: $0 PYSÄKKIKOODI..." >&2
	exit 1
fi

if [ -f "$REPO_DIR/config/config.env" ]; then
	set -a
	. "$REPO_DIR/config/config.env"
	set +a
fi
if [ -z "${HSL_APIKEY:-}" ]; then
	echo "HSL_APIKEY puuttuu tiedostosta $REPO_DIR/config/config.env" >&2
	exit 1
fi

for code in "$@"; do
	curl -fsS "$API_URL" \
		-H "Content-Type: application/graphql" \
		-H "digitransit-subscription-key: $HSL_APIKEY" \
		--data "{ stops(name: \"$code\") { gtfsId code name desc } }" |
		python3 -c '
import json, sys
code = sys.argv[1]
stops = json.load(sys.stdin).get("data", {}).get("stops") or []
found = [s for s in stops if (s.get("code") or "").upper() == code.upper()]
if not found:
    print(f"// {code}: pysäkkiä ei löytynyt")
for s in found:
    stop_id = s["gtfsId"].split(":", 1)[1]
    name = s["name"]
    desc = " (" + s["desc"] + ")" if s.get("desc") else ""
    print(f"{{ id: {stop_id} }}, // {code} {name}{desc}")
' "$code"
done
