'use strict';

module.exports = {

	/* APP CONFIG */
	APP_NAME: 					'now@ucsandiego',
	GOOGLE_ANALYTICS_ID: 		'UA-59591330-3',
	DEBUG_ENABLED: 				false,				// Disables all logger functions (i.e. logger.log) if set to false (console.log is unaffected)
	NAVIGATOR_ENABLED: 			false,				// IOS setting only - if true, app uses Navigator instead of Navigator IOS
													// Navigator will always be used for Android
	
	/* CARDS */
	SHUTTLE_CARD_ENABLED: 		true,
	WEATHER_CARD_ENABLED: 		true,
	EVENTS_CARD_ENABLED: 		true,
	NEWS_CARD_ENABLED: 			true,
	NEARBY_CARD_ENABLED: 		true,
	DINING_CARD_ENABLED: 		true,

	/* APIS / ENDPOINTS */
	WEATHER_API_URL: 			'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast',
	SURF_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/surffeed.json',
	NEWS_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json',
	EVENTS_API_URL: 			'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/student_events.json',
	SHUTTLE_STOPS_API_URL: 		'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/stops/',
	DINING_API_URL: 			'https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod',
	FEEDBACK_URL: 				'https://eforms.ucsd.edu/view.php?id=175631',
	NODE_MARKERS_BASE_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/nearby_markers/',
	WEATHER_ICON_BASE_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/',
	WELCOME_WEEK_API_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/welcome_week_events.json',

};