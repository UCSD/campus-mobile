'use strict';

module.exports = {

	/* APP CONFIG */
	APP_NAME: 					'now@ucsandiego',
	GOOGLE_ANALYTICS_ID: 		'UA-XXXXXXXX-X',	// Update with your Google Analytics ID
	DEBUG_ENABLED: 				true,

	/* CARDS */
	PUSH_CARD_ENABLED: 			false,
	SHUTTLE_CARD_ENABLED: 		true,
	WEATHER_CARD_ENABLED: 		true,
	EVENTS_CARD_ENABLED: 		true,
	TOPSTORIES_CARD_ENABLED: 	true,
	DESTINATION_CARD_ENABLED: 	true,
	DINING_CARD_ENABLED: 		false,

	/* APIS / ENDPOINTS */
	WEATHER_API_URL: 			'http://www.sample.com/weather.json?3', 			// see ./app/json/samples/weather.json
	SURF_API_URL: 				'http://www.sample.com/surf.json', 				// see ./app/json/samples/surf.json
	TOP_STORIES_API_URL: 		'http://www.sample.com/news.json', 				// see ./app/json/samples/news.json
	EVENTS_API_URL: 			'http://www.sample.com/events.json', 			// see ./app/json/samples/events.json
	SHUTTLE_STOPS_API_URL: 		'http://www.sample.com/shuttle_stops.json', 	// see ./app/json/samples/shuttle_stops.json
	NODE_MARKERS_BASE_URL: 		'http://www.sample.com/node_marker_1.json', 	// see ./app/json/samples/node_marker_1.json
	FEEDBACK_URL: 				'http://www.sample.com/feedback.html',
	PRIVACY_POLICY_URL: 		'http://www.sample.com/privacy_policy.html',



	DB_SCHEMA: {
		name: 'AppSettings',
		primaryKey: 'id',
		properties: {
			/* PRIMARY KEY */
			id: 							{ type: 'int',  default: 1 },
			/* PERSISTENT VALS */
			MODAL_ENABLED: 					{ type: 'bool', default: true },
		}
	}
};