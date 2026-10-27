/* MagicMirror² – peilin asetukset
 *
 * Tämä tiedosto linkitetään Pi:llä polkuun ~/MagicMirror/config/config.js.
 * Muuttujat muodossa ${NIMI} tulevat tiedostosta config/config.env.
 *
 * Dokumentaatio: https://docs.magicmirror.builders/configuration/introduction.html
 */
let config = {
	address: "localhost",
	port: 8080,
	basePath: "/",
	ipWhitelist: ["127.0.0.1", "::ffff:127.0.0.1", "::1"],

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
				// Helsinki – vaihda omiin koordinaatteihin
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
			// Pysäkin numero löytyy Reittioppaasta: avaa pysäkki osoitteessa
			// https://reittiopas.hsl.fi ja katso osoiteriviltä "HSL:1130113" -> 1130113
			module: "mm-hsl-timetable",
			position: "middle_center",
			header: "Lähtevät",
			config: {
				apikey: "${HSL_APIKEY}",
				busCount: 5,
				stops: [
					// Esimerkki – vaihda omiin pysäkkeihin.
					// minutesFrom piilottaa lähdöt, joihin ei enää ehdi kävellä.
					{ id: 1130113, minutesFrom: 0 }
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
