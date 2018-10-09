module.exports = {

	/* APP CONFIG */
	APP_NAME: 'Campus Mobile',
	GOOGLE_ANALYTICS_ID: 'GOOGLE_ANALYTICS_ID_PH',

	/* APIs / FEEDS */
	WEATHER_API_URL: 'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast?',
	SURF_API_URL: 'https://kusyfng6mg.execute-api.us-west-2.amazonaws.com/prod/v1/surf',
	SHUTTLE_STOPS_API_URL: 'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/v2/stops/',
	SHUTTLE_VEHICLES_API_URL: 'https://hjr84cay81.execute-api.us-west-2.amazonaws.com/prod?route=',
	DINING_API_URL: 'https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v3/dining',
	EVENTS_API_URL: 'https://2jjml3hf27.execute-api.us-west-2.amazonaws.com/prod/events/student',
	QUICKLINKS_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/quick_links/ucsd-quicklinks-v3.json',
	NEWS_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json',
	MAP_SEARCH_API_URL: 'https://xgu9qa7gx4.execute-api.us-west-2.amazonaws.com/prod/v2/map/search?region=0&query=',
	SPECIAL_EVENT_API_URL: 'https://2jjml3hf27.execute-api.us-west-2.amazonaws.com/prod/events/special',
	ACADEMIC_TERM_API_URL: 'https://btgre7sss6.execute-api.us-west-2.amazonaws.com/prod/v1/term/current',
	ACADEMIC_TERM_FINALS_API_URL(isStudentDemo) {
		if (isStudentDemo) return 'https://pad7kcyzo1.execute-api.us-west-2.amazonaws.com/prod/v1/demo/term/current/finals'
		else return 'https://btgre7sss6.execute-api.us-west-2.amazonaws.com/prod/v1/term/current/finals'
	},

	/* DEV ENDPOINTS - UPDATE TO PROD */
	AUTH_SERVICE_API_URL: 'https://3hepzvdimd.execute-api.us-west-2.amazonaws.com/dev/v1/access-profile',
	// AUTH_SERVICE_API_URL: ’https://c12cf2xke8.execute-api.us-west-2.amazonaws.com/prod/v1/access-profile',
	ACADEMIC_HISTORY_API_URL(isStudentDemo) {
		if (isStudentDemo) return 'https://pad7kcyzo1.execute-api.us-west-2.amazonaws.com/prod/v1/demo/student/class_list'
		else return 'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list'
	},
	PARKING_API_URL: 'https://8tcoih8tu0.execute-api.us-west-2.amazonaws.com/dev/parking/v1.0/406/status',
	TOPICS_API_URL: 'https://bvgjvzaakl.execute-api.us-west-2.amazonaws.com/dev/topics',
	MYMESSAGES_API_URL: 'https://api-qa.ucsd.edu:8243/mp-mymessages/1.0.0',
	MESSAGES_TOPICS_URL: 'https://s3-us-west-1.amazonaws.com/ucsd-mobile-dev/mock-apis/messaging/topics.json',
	PUSH_REGISTRATION_API_URL: 'https://api-qa.ucsd.edu:8243/mp-registration/1.0.0',
	USER_PROFILE_API_URL: 'https://api-qa.ucsd.edu:8243/mp-registration/1.0.0/profile',
	/* END DEV ENDPOINTS */

	/* RESOURCES */
	SHUTTLE_SCHEDULE_URL: 'https://transportation.ucsd.edu/shuttles/',
	PRIVACY_POLICY_URL: 'https://mobile.ucsd.edu/privacy-policy.html',
	FEEDBACK_URL: 'https://eforms.ucsd.edu/view.php?id=175631',
	WEATHER_ICON_BASE_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/',
	SHUTTLE_ROUTES_MASTER: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_routes_master_map.json',
	SHUTTLE_STOPS_MASTER: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_stops_master_map.json',
	SHUTTLE_STOPS_MASTER_NO_ROUTES: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_stops_master_map_no_routes.json',
	ACCOUNT_HELP_URL: 'https://acms.ucsd.edu/students/accounts-and-passwords/index.html',

	/* API TTLs */
	LOCATION_TTL: 5000, // 5 seconds
	SHUTTLE_API_TTL: 15000, // 15 seconds
	DATA_SAGA_TTL: 60000, // 1 minute
	SCHEDULE_TTL: 300000,  // 5 minutes
	PARKING_API_TTL: 300000,	// 5 minutes
	WEATHER_API_TTL: 1800000, // 30 minutes
	SURF_API_TTL: 1800000, // 30 minutes
	SPECIAL_EVENTS_TTL: 1800000, // 30 minutes
	EVENTS_API_TTL: 3600000, // 1 hour
	NEWS_API_TTL: 3600000, // 1 hour
	DINING_API_TTL: 3600000, // 1 hour
	DINING_MENU_API_TTL: 3600000, // 1 hour
	SHUTTLE_MASTER_TTL: 3600000, // 1 hour
	USER_PROFILE_SYNC_TTL: 3600000, // 1 hour
	QUICKLINKS_API_TTL: 86400000, // 1 day

	/* REQUEST TIMEOUTS */
	HTTP_REQUEST_TTL: 10000, // 10 seconds
	SSO_TTL: 15000, // 15 seconds
	MESSAGING_TTL: 10000, // 10 seconds

	/* RETRIES */
	SSO_IDP_ERROR_RETRY_INCREMENT: 10000, // 10 seconds
	SSO_REFRESH_MAX_RETRIES: 3,
	SSO_REFRESH_RETRY_INCREMENT: 5000, // 5 seconds
	SSO_REFRESH_RETRY_MULTIPLIER: 3, // Multiplies increment by this amount for next try

}
