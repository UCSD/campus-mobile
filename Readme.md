## now@ucsandiego.app

## License

	MIT

## Installation

	// From project folder run:
	npm install

	// Link third party modules with rnpm
	rnpm link

## Release Notes

The file ./app/AppSettings.js is required by the now@ucsandiego app, but has been omitted
from the repo intentionally. Before attempting to run the project, create the file 
./app/AppSettings.js with following data below.

Reference the folder ./app/json/samples/ for samples.

## AppSettings.js

	/***** ./app/AppSettings.js START *****/
	'use strict';

	module.exports = {

		/* APP CONFIG */
		APP_NAME: 					'now@ucsandiego',
		GOOGLE_ANALYTICS_ID: 		'UA-XXXXXXXX-X',	// Update with your Google Analytics ID
		DEBUG_ENABLED: 				true,
		NAVIGATOR_ENABLED: 			true,		// IOS setting only - if true, use Navigator instead of Navigator IOS. Navigator will always be used for Android
		
		/* CARDS */
		SHUTTLE_CARD_ENABLED: 		true,
		WEATHER_CARD_ENABLED: 		true,
		EVENTS_CARD_ENABLED: 		true,
		TOPSTORIES_CARD_ENABLED: 	true,
		NEARBY_CARD_ENABLED: 		true,
		DINING_CARD_ENABLED: 		false,
	
		/* APIS / ENDPOINTS */
		WEATHER_API_URL: 			'http://www.sample.com/weather.json', 			// see ./app/json/samples/weather.json
		SURF_API_URL: 				'http://www.sample.com/surf.json', 				// see ./app/json/samples/surf.json
		TOP_STORIES_API_URL: 		'http://www.sample.com/news.json', 				// see ./app/json/samples/news.json
		EVENTS_API_URL: 			'http://www.sample.com/events.json', 			// see ./app/json/samples/events.json
		SHUTTLE_STOPS_API_URL: 		'http://www.sample.com/shuttle_stops.json', 	// see ./app/json/samples/shuttle_stops.json
		NODE_MARKERS_BASE_URL: 		'http://www.sample.com/node_marker_1.json', 	// see ./app/json/samples/node_marker_1.json
		FEEDBACK_URL: 				'http://www.sample.com/feedback.html',
		PRIVACY_POLICY_URL: 		'http://www.sample.com/privacy_policy.html', 
		DINING_API_URL: 			'http://www.sample.com/dining-feed.json',
		WEATHER_ICON_BASE_URL: 		'http://www.sample.com/weather-icons/',
		WELCOME_WEEK_URL: 			'http://www.sample.com/welcome-week/',

	};
	/***** ./app/AppSettings.js END *****/


