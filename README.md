# MagicMirror² – Raspberry Pi

Oman taikapeilin asetukset ja asennusskriptit. Kaikki omat asetukset ovat
tässä repossa, joten jos Pi:n muistikortti hajoaa, peilin saa takaisin
asentamalla käyttöjärjestelmän uudelleen ja ajamalla yhden skriptin.

**Laitteisto:** Raspberry Pi 3B/3B+, pystyasentoon käännetty näyttö, PIR-liiketunnistin

**Moduulit:**

| Moduuli | Mitä tekee |
| --- | --- |
| `clock`, `weather`, `newsfeed` | Kello, sääennuste (Open-Meteo) ja Ylen uutiset (MagicMirrorin omat moduulit) |
| [mm-hsl-timetable](https://github.com/ZakarFin/mm-hsl-timetable) | HSL-lähdöt valituilta pysäkeiltä |
| [MMM-AmbientWeather](https://github.com/hearter20176/MMM-AmbientWeather) | Oman Ambient Weather -sääaseman mittaukset |
| [MMM-MyScoreboard](https://github.com/dathbe/MMM-MyScoreboard) | Suosikkijoukkueiden ottelutulokset |
| [MMM-Remote-Control](https://github.com/Jopyth/MMM-Remote-Control) | Peilin ohjaus puhelimella tai selaimella |
| [MMM-Universal-Pir](https://gitlab.com/khassel/MMM-Universal-Pir) | Sammuttaa näytön, kun lähellä ei ole liikettä |

## Rakenne

```
config/config.js          MagicMirrorin asetukset (moduulit)
config/custom.css         Omat tyylit
config/config.env.example Malli salaisuuksille (API-avain, GPIO, näytön kierto)
config/config.env         Omat arvot – EI GitHubissa (.gitignore)
modules.txt               Asennettavat lisämoduulit
scripts/install.sh        Asentaa/päivittää kaiken
scripts/start-mm.sh       Käynnistää peilin (ajetaan automaattisesti)
scripts/screen.sh         Näyttö päälle/pois + pystykierto
scripts/pir-watch.sh      Lukee liiketunnistinta
```

`install.sh` linkittää `config.js`, `custom.css` ja `config.env` tiedostot
kansioon `~/MagicMirror/config/`, joten muutokset tehdään aina tähän repoon.

## 1. Käyttöjärjestelmä

1. Asenna tietokoneelle [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
2. Valitse laitteeksi **Raspberry Pi 3** ja käyttöjärjestelmäksi
   **Raspberry Pi OS (64-bit)** (työpöytäversio, ei Lite).
3. Asetuksista: käyttäjänimi ja salasana, WiFi, aikavyöhyke `Europe/Helsinki`,
   näppäimistö `fi` ja **SSH päälle**.
4. Kirjoita kortti, laita se Pi:hin ja käynnistä.

> Vinkki: Yleisin syy peilin "sekoamiseen" on korruptoitunut muistikortti.
> Käytä virallista virtalähdettä (Pi 3: 5 V / 2,5 A) ja laadukasta
> A1/A2-muistikorttia.

## 2. Asennus

Ota SSH-yhteys Pi:hin (`ssh kayttaja@raspberrypi.local`) ja aja:

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git
git clone https://github.com/ggashion/ggashion.git ~/ggashion
~/ggashion/scripts/install.sh
```

Asennus kestää Pi 3:lla noin 15–30 minuuttia.

## 3. HSL-aikataulut

1. Rekisteröidy ilmaiseksi osoitteessa <https://portal-api.digitransit.fi>,
   tilaa tuote (*subscription*) ja kopioi avain (*primary key*).
2. Lisää avain tiedostoon `~/ggashion/config/config.env`:
   ```
   HSL_APIKEY=avaimesi-tähän
   ```
3. Etsi pysäkki osoitteesta <https://reittiopas.hsl.fi>. Kun avaat pysäkin,
   osoiterivillä näkyy esim. `.../pysakit/HSL:1130113`. Numero `1130113`
   on pysäkin tunnus.
4. Lisää tunnus `config/config.js`-tiedostoon kohtaan `stops`. Pysäkkejä voi olla
   useita:
   ```js
   stops: [
   	{ id: 1130113 },
   	{ id: 1130114, name: "Kotipysäkki", minutesFrom: 3 }
   ]
   ```
   `minutesFrom` piilottaa lähdöt, joihin et enää ehdi kävellä.

## 4. Ambient Weather -sääasema

Moduuli näyttää oman Ambient Weather -sääasemasi tiedot, joten se vaatii
aseman, joka on yhdistetty palveluun ambientweather.net.

1. Kirjaudu osoitteessa <https://ambientweather.net> ja avaa
   **Account → API Keys**.
2. Luo **API Key** ja **Application Key**.
3. Lisää ne tiedostoon `config/config.env`:
   ```
   AMBIENT_APIKEY=...
   AMBIENT_APPKEY=...
   AMBIENT_MAC=          # tarvitaan vain, jos tilillä on useampi asema
   ```
4. Vaihda `config.js`-tiedostoon omat koordinaatit (`latitude`/`longitude`,
   enintään 4 desimaalia). Samat koordinaatit kannattaa laittaa myös
   sääennusteelle (`lat`/`lon`).

Moduulin oma sääennuste tulee Yhdysvaltain sääpalvelusta eikä toimi
Suomessa. Siksi ennuste näytetään MagicMirrorin omalla `weather`-moduulilla.

## 5. Urheilutulokset

Urheilutulokset eivät tarvitse API-avainta. Valitse `config.js`-tiedostossa
kohtaan `sports` liigat ja joukkueet. Liigojen nimet ja joukkueiden koodit löytyvät
[moduulin README:stä](https://github.com/dathbe/MMM-MyScoreboard#available-leagues).

```js
sports: [
	{ league: "NHL", teams: ["FLA", "NSH"] },
	{ league: "English Premier League", teams: ["LIV"] }
]
```

Moduuli hakee tiedot ESPN:stä, eikä Liiga tai Veikkausliiga ole mukana.

## 6. Ohjaus puhelimella (Remote-Control)

Avaa samassa kotiverkossa selaimella `http://<pi:n-ip-osoite>:8080/remote.html`.
Pi:n IP-osoitteen saat komennolla `hostname -I`. Näkymän voi lisätä puhelimen
kotinäytölle.

Remote-Controlilla voi piilottaa ja näyttää moduuleja, sammuttaa näytön sekä
käynnistää peilin tai Pi:n uudelleen.

- Peiliin pääsee vain kotiverkosta (`192.168.x.x`). Jos kotiverkkosi osoitteet
  alkavat `10.` tai `172.`, lisää ne `ipWhitelist`-listaan `config.js`:ssä.
- **Älä käytä Remote-Controlin asetuseditoria**, koska se kirjoittaa
  `config.js`-tiedoston yli. Muokkaa asetuksia tässä repossa.

## 7. Pystynäyttö

Kierto asetetaan tiedostoon `config/config.env`:

```
MM_SCREEN_TRANSFORM=90
```

Jos kuva on ylösalaisin, vaihda arvoksi `270`. Kokeile ilman uudelleenkäynnistystä:

```bash
set -a; . ~/ggashion/config/config.env; set +a
~/ggashion/scripts/screen.sh on
```

Jos näyttöä ei löydy, tarkista lähdön nimi komennolla `wlr-randr` ja päivitä
`MM_SCREEN_OUTPUT`. Näytön tilan näet komennolla `screen.sh status`.

## 8. Liiketunnistin (PIR)

Esim. HC-SR501-anturin kytkentä (Pi:n pinninumerot):

| Anturi | Pi |
| --- | --- |
| VCC | pinni 2 (5 V) |
| GND | pinni 6 (GND) |
| OUT | pinni 16 (GPIO23) |

HC-SR501:n lähtö on 3,3 V, joten se voidaan kytkeä suoraan Pi:hin.
Anturissa on kaksi säätöruuvia, joilla säädetään herkkyys ja pitoaika.
Pitoaika kannattaa kääntää lyhyeksi, koska sammutusviive säädetään peilin
asetuksissa. Jumpperi asentoon *repeat* (H).

**Testaa anturi ennen peiliä:**

```bash
~/ggashion/scripts/pir-watch.sh
```

Heiluta kättä anturin edessä: jokaisesta liikkeestä pitäisi tulostua rivi.
Lopeta painamalla `Ctrl+C`.

**Testaa näytön sammutus:**

```bash
~/ggashion/scripts/screen.sh off
~/ggashion/scripts/screen.sh on
```

Sammutusviive säädetään `config.js`-tiedostossa kohdassa `deactivateDelay`
(oletus 5 minuuttia). Jos haluat nähdä jäljellä olevan ajan peilissä
testauksen ajan, aseta `showCountDown: true`.

## Käyttö

```bash
pm2 logs MagicMirror      # lokit (virheiden etsintä)
pm2 restart MagicMirror   # käynnistä uudelleen asetusten muuttamisen jälkeen
~/ggashion/scripts/install.sh   # päivitä MagicMirror ja moduulit
```

### Asetusten muokkaus

Muokkaa tiedostoja joko suoraan Pi:llä (`nano ~/ggashion/config/config.js`)
tai GitHubissa ja hae muutokset Pi:lle:

```bash
cd ~/ggashion && git pull && pm2 restart MagicMirror
```

### Uusi moduuli

1. Etsi moduuli: <https://modules.magicmirror.builders>
2. Lisää sen git-osoite tiedostoon `modules.txt`
3. Lisää asetukset tiedostoon `config/config.js`
4. Aja `~/ggashion/scripts/install.sh`
