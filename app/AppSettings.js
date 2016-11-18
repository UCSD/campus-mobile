module.exports = {

	/* APP CONFIG */
	APP_NAME: 					'now@ucsandiego',
	GOOGLE_ANALYTICS_ID: 		'UA-59591330-3',
	DEBUG_ENABLED: 				false, // Disables all logger functions (i.e. logger.log) if set to false (console.log is unaffected)

	/* APIs / FEEDS */
	WEATHER_API_URL: 			'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast',
	SURF_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/surffeed.json',
	SHUTTLE_STOPS_API_URL: 		'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/stops/',
	EVENTS_API_URL: 			'https://evv6vpvob6.execute-api.us-west-2.amazonaws.com/prod/',
	DINING_API_URL: 			'https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v2/dining/locations',
	NEWS_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json',
	QUICKLINKS_API_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-mobile/dev/ucsd-quicklinks.json',

	/* RESOURCES */
	FEEDBACK_URL: 				'https://eforms.ucsd.edu/view.php?id=175631',
	NODE_MARKERS_BASE_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/nearby_markers/',
	WEATHER_ICON_BASE_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/',
	WELCOME_WEEK_API_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/welcome_week_events.json',

	/* API TTL (seconds) */
	WEATHER_API_TTL: 			3600,
	SURF_API_TTL: 				3600,
	SHUTTLE_STOPS_API_TTL: 		3600,
	EVENTS_API_TTL: 			3600,
	DINING_API_TTL: 			60,
	QUICKLINKS_API_TTL: 		86400,

};
