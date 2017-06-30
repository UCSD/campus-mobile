module.exports = {

	/* APP CONFIG */
	APP_NAME: 'Campus Mobile',
	GOOGLE_ANALYTICS_ID: 'UA-XXXXXXXX-X',

	/* APIs / FEEDS */
	WEATHER_API_URL: 'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast?',
	SURF_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/surffeed.json',
	SHUTTLE_STOPS_API_URL: 'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/v2/stops/',
	SHUTTLE_VEHICLES_API_URL: 'https://hjr84cay81.execute-api.us-west-2.amazonaws.com/prod?route=',
	//DINING_API_URL: 'https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v2/dining/locations',
	DINING_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-mobile/dev/dining/dining_v2_nomenu_2017-06-02.json', // HDH V2 Placeholder Feed
	DINING_MENU_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-mobile/dev/dining/menu/', // HDH V2 Placeholder Feed
	EVENTS_API_URL: 'https://2jjml3hf27.execute-api.us-west-2.amazonaws.com/prod/events/student',
	QUICKLINKS_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/quick_links/ucsd-quicklinks-v3.json',
	NEWS_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json',
	MAP_SEARCH_API_URL: 'https://xgu9qa7gx4.execute-api.us-west-2.amazonaws.com/prod/v2/map/search?region=0&query=',
	CAMPUS_LISA_URL: 'https://95dscnn6od.execute-api.us-west-2.amazonaws.com/prod/v1/schedule',

	/* RESOURCES */
	SHUTTLE_SCHEDULE_URL: 'https://transportation.ucsd.edu/shuttles/',
	FEEDBACK_URL: 'https://eforms.ucsd.edu/view.php?id=175631',
	NODE_MARKERS_BASE_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/nearby_markers/',
	WEATHER_ICON_BASE_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/',
	SHUTTLE_ROUTES_MASTER: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_routes_master_map.json',
	SHUTTLE_STOPS_MASTER: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_stops_master_map.json',
	SHUTTLE_STOPS_MASTER_NO_ROUTES: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_stops_master_map_no_routes.json',

	/* TTLs */
	WEATHER_API_TTL: 0.18, // 180ms
	SURF_API_TTL: 0.18 , // 180ms
	EVENTS_API_TTL: 0.36, // 360ms
	NEWS_API_TTL: 0.36, // 360ms
	DINING_API_TTL: 0.36, // 360ms
	QUICKLINKS_API_TTL: 0.48, // 480ms
	SHUTTLE_API_TTL: 0.06, // 60ms
	SHUTTLE_MASTER_TTL: 0.86, // 860ms
	SPECIAL_EVENTS_TTL: 0.21, // 210ms
	DATA_SAGA_TTL: 0.06, // 60ms

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
