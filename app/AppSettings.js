module.exports = {

	/* APP CONFIG */
	APP_NAME: 					'Campus Mobile',
	APP_VERSION: 				'5.0',
	APP_CODEPUSH_VERSION: 		'1',
	GOOGLE_ANALYTICS_ID: 		'GOOGLE_ANALYTICS_ID_PH',
	DEBUG_ENABLED: 				false, 	// Disables all logger functions (i.e. logger.log, logger.error).
									   	// Use console.log/error as necessary but do not commit code using console.log/error

	/* APIs / FEEDS */
	WEATHER_API_URL: 			'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast?',
	SURF_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/surffeed.json',
	SHUTTLE_STOPS_API_URL: 		'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/stops/',
	DINING_API_URL: 			'https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v2/dining/locations',
	EVENTS_API_URL: 			'https://evv6vpvob6.execute-api.us-west-2.amazonaws.com/prod/',
	QUICKLINKS_API_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/quick_links/ucsd-quicklinks-v2.json',
	NEWS_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json',
	MAP_SEARCH_API_URL: 		'https://xgu9qa7gx4.execute-api.us-west-2.amazonaws.com/prod/map/search?region=0&query=',
	WELCOME_WEEK_API_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/welcome_week_events.json',

	/* RESOURCES */
	FEEDBACK_URL: 				'https://eforms.ucsd.edu/view.php?id=175631',
	NODE_MARKERS_BASE_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/nearby_markers/',
	WEATHER_ICON_BASE_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/',

	/* API TTL (seconds) */
	WEATHER_API_TTL: 			1800,		// 30 minutes
	SURF_API_TTL: 				1800,		// 30 minutes
	EVENTS_API_TTL: 			3600,		// 1 hour
	NEWS_API_TTL: 				3600,		// 1 hour
	DINING_API_TTL: 			21600,		// 6 hours
	QUICKLINKS_API_TTL: 		604800,		// 1 week

	USER_LOGIN: {
		ENABLED: false,
		METHOD: 'openid',
		OPTIONS: {
			CLIENT_ID: 'campusimplicit',
			AUTH_URL: 'https://auth-dev.ucdavis.edu/identity/connect/authorize',
			USER_INFO_URL: 'https://auth-dev.ucdavis.edu/identity/connect/userinfo',
			REDIRECT_URL: 'campusmobile://cb',
			STATE: 'M9NGbE6bnUV18FflfVeZ2U0j94'
		}
	}
};