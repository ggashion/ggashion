/* MagicMirror² – peilin asetukset
 *
 * Tämä tiedosto linkitetään Pi:llä polkuun ~/MagicMirror/config/config.js.
 * Muuttujat muodossa ${NIMI} tulevat tiedostosta config/config.env.
 *
 * Dokumentaatio: https://docs.magicmirror.builders/configuration/introduction.html
 */
let config = {
	// 0.0.0.0 = peiliin pääsee myös muilta laitteilta (MMM-Remote-Control)
	address: "0.0.0.0",
	port: 8080,
	basePath: "/",
	// Sallitaan Pi itse ja kotiverkon laitteet (192.168.x.x).
	// Jos kotiverkkosi osoitteet alkavat 10. tai 172., lisää ne tähän.
	ipWhitelist: ["127.0.0.1", "::ffff:127.0.0.1", "::1", "::ffff:192.168.0.0/112", "192.168.0.0/16"],

	language: "fi",
	locale: "fi-FI",
	logLevel: ["INFO", "LOG", "WARN", "ERROR"],
	timeFormat: 24,
	units: "metric",

	modules: [
		{
			module: "alert"
		},
		{
			module: "updatenotification",
			position: "top_bar"
		},
		{
			module: "clock",
			position: "top_left",
			config: {
				showWeek: true
			}
		},
		{
			module: "weather",
			position: "top_right",
			config: {
				weatherProvider: "openmeteo",
				type: "current",
				// Helsinki
				lat: 60.1699,
				lon: 24.9384
			}
		},
		{
			module: "weather",
			position: "top_right",
			header: "Sääennuste",
			config: {
				weatherProvider: "openmeteo",
				type: "forecast",
				lat: 60.1699,
				lon: 24.9384
			}
		},
		{
			// HSL-aikataulut: https://github.com/ZakarFin/mm-hsl-timetable
			// Moduuli tarvitsee pysäkin tunnuksen, ei pysäkkikoodia (H1234).
			// Tunnus näkyy Reittioppaassa (https://reittiopas.hsl.fi) pysäkin
			// osoiterivillä, esim. ".../pysakit/HSL:1130113" -> 1130113
			module: "mm-hsl-timetable",
			position: "middle_center",
			header: "Lähtevät",
			config: {
				apikey: "${HSL_APIKEY}",
				busCount: 5,
				// minutesFrom piilottaa lähdöt, joihin ei enää ehdi kävellä, esim.
				// { id: 1234567, minutesFrom: 3 }
				stops: [
					// TODO: lisää pysäkkien tunnukset
					// H3486
					// H3529
					// H4534
				]
			}
		},
		{
			// Urheilutulokset: https://github.com/dathbe/MMM-MyScoreboard
			// Liigat ja joukkuekoodit löytyvät moduulin README:stä.
			// Näyttää liigojen kaikki päivän ottelut. Pelkät suosikkijoukkueet
			// saa lisäämällä liigalle esim. teams: ["BAR", "RMA"].
			module: "MMM-MyScoreboard",
			position: "bottom_right",
			header: "Tulokset",
			config: {
				viewStyle: "oneLineWithLogos",
				// Jos otteluita on paljon, lista vierii tämän korkeuden sisällä (px)
				maxHeight: 400,
				sports: [
					{ league: "ESP_LALIGA", label: "La Liga" },
					{ league: "English Premier League", label: "Valioliiga" },
					{ league: "UEFA_CHAMPIONS", label: "Mestarien liiga" }
				]
			}
		},
		{
			module: "newsfeed",
			position: "bottom_bar",
			config: {
				feeds: [
					{
						title: "Yle Uutiset",
						url: "https://feeds.yle.fi/uutiset/v1/majorHeadlines/YLE_UUTISET.rss"
					}
				],
				showSourceTitle: true,
				showPublishDate: true
			}
		},
		{
			// Ohjaus selaimella tai puhelimella: http://<pi:n-ip>:8080/remote.html
			// https://github.com/Jopyth/MMM-Remote-Control
			//
			// HUOM: Älä käytä Remote-Controlin asetuseditoria. Se kirjoittaisi
			// tämän tiedoston yli. Muokkaa asetuksia tässä repossa.
			// Jos haluat osoitteen ja QR-koodin näkyviin peiliin, lisää esim.
			// position: "bottom_left"
			module: "MMM-Remote-Control",
			config: {
				// Näytön ohjaus samoilla skripteillä kuin liiketunnistimella
				customCommand: {
					monitorOnCommand: "${MIRROR_DIR}/scripts/screen.sh on",
					monitorOffCommand: "${MIRROR_DIR}/scripts/screen.sh off",
					monitorStatusCommand: "${MIRROR_DIR}/scripts/screen.sh status"
				}
			}
		},
		{
			// Liiketunnistin: https://gitlab.com/khassel/MMM-Universal-Pir
			// Näyttö sammuu, kun liikettä ei ole havaittu deactivateDelay-ajan.
			module: "MMM-Universal-Pir",
			position: "bottom_left",
			config: {
				gpioCommand: "${MIRROR_DIR}/scripts/pir-watch.sh",
				onCommand: "${MIRROR_DIR}/scripts/screen.sh on",
				offCommand: "${MIRROR_DIR}/scripts/screen.sh off",
				deactivateDelay: 5 * 60 * 1000, // 5 minuuttia
				showCountDown: false,
				title: "Näyttö sammuu"
			}
		}
	]
};

/*************** DO NOT EDIT THE LINE BELOW ***************/
if (typeof module !== "undefined") { module.exports = config; }
