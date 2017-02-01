module.exports = {

	/* APP CONFIG */
	APP_VERSION: 				'2.4',
	APP_CODEPUSH_VERSION: 		'3',
	APP_NAME: 					'now-mobile',
	APP_CAMPUS_NAME: 			'APP_CAMPUS_NAME_PH',
	GOOGLE_ANALYTICS_ID: 		'GOOGLE_ANALYTICS_ID_PH',
	DEBUG_ENABLED: 				false, // Disables all logger functions (i.e. logger.log) if set to false (console.log is unaffected)

	/* APIs / FEEDS */
	WEATHER_API_URL: 			'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast',
	SURF_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/surffeed.json',
	SHUTTLE_STOPS_API_URL: 		'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/stops/',
	DINING_API_URL: 			'https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v2/dining/locations',
	EVENTS_API_URL: 			'https://evv6vpvob6.execute-api.us-west-2.amazonaws.com/prod/',
	QUICKLINKS_API_URL: 		'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/quick_links/ucsd-quicklinks.json',
	NEWS_API_URL: 				'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json',
	MAP_SEARCH_API_URL: 		'https://xgu9qa7gx4.execute-api.us-west-2.amazonaws.com/prod/map/search?region=0&query=',

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

	USER_LOGIN: {
		ENABLED: false,
		METHOD: 'openid',
		OPTIONS: {
			CLIENT_ID: 'nowimplicit',
			AUTH_URL: 'https://auth-dev.ucdavis.edu/identity/connect/authorize',
			USER_INFO_URL: 'https://auth-dev.ucdavis.edu/identity/connect/userinfo',
			REDIRECT_URL: 'nowmobile://cb',
			STATE: 'M9NGbE6bnUV18FflfVeZ2U0j94'
		}
	}
};
