module.exports = {

	/* APP CONFIG */
	APP_NAME: 'CampusMobile',
	GOOGLE_ANALYTICS_ID: 'GOOGLE_ANALYTICS_ID_PH',

	/* ENDPOINTS */
	// SSO
	AUTH_SERVICE_API_URL: 'https://c12cf2xke8.execute-api.us-west-2.amazonaws.com/prod/v1.1/access-profile',
	// ACADEMIC
	ACADEMIC_TERM_API_URL: 'https://btgre7sss6.execute-api.us-west-2.amazonaws.com/prod/v1/term/current',
	ACADEMIC_TERM_FINALS_API_URL: 'https://btgre7sss6.execute-api.us-west-2.amazonaws.com/prod/v1/term/current/finals',
	ACADEMIC_HISTORY_API_URL: 'https://api.ucsd.edu:8243/student/my/academic_history/v1/class_list',
	SI_SESSIONS_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/TLC_SI_DATA.json',
	// MESSAGING
	TOPICS_API_URL: 'https://h6rc133pbh.execute-api.us-west-2.amazonaws.com/prod/topics',
	MYMESSAGES_API_URL: 'https://api.ucsd.edu:8243/mp-mymessages/1.0.0',
	MP_REGISTRATION_API_URL: 'https://api.ucsd.edu:8243/mp-registration/1.0.0',
	MESSAGES_TOPICS_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/topics.json',
	// SHUTTLE
	SHUTTLE_STOPS_API_URL: 'https://ies4wyrlx9.execute-api.us-west-2.amazonaws.com/prod/v2/stops/',
	SHUTTLE_VEHICLES_API_URL: 'https://hjr84cay81.execute-api.us-west-2.amazonaws.com/prod?route=',
	SHUTTLE_ROUTES_MASTER: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_routes_master_map.json',
	SHUTTLE_STOPS_MASTER: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_stops_master_map.json',
	SHUTTLE_STOPS_MASTER_NO_ROUTES: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/shuttle_stops_master_map_no_routes.json',
	// OTHER
	NEWS_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json',
	EVENTS_API_URL: 'https://2jjml3hf27.execute-api.us-west-2.amazonaws.com/prod/events/student',
	SPECIAL_EVENT_API_URL: 'https://2jjml3hf27.execute-api.us-west-2.amazonaws.com/prod/events/special',
	WEATHER_API_URL: 'https://w3wyps9yje.execute-api.us-west-2.amazonaws.com/prod/forecast?',
	SURF_API_URL: 'https://kusyfng6mg.execute-api.us-west-2.amazonaws.com/prod/v1/surf',
	DINING_API_URL: 'https://pg83tslbyi.execute-api.us-west-2.amazonaws.com/prod/v3/dining',
	MAP_SEARCH_API_URL: 'https://xgu9qa7gx4.execute-api.us-west-2.amazonaws.com/prod/v2/map/search?region=0&query=',
	FEEDBACK_URL: 'https://eforms.ucsd.edu/view.php?id=175631',
	QUICKLINKS_API_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/quick_links/ucsd-quicklinks-v3.json',
	PARKING_API_URL: 'https://b2waxbcovi.execute-api.us-west-2.amazonaws.com/prod/parking/v1.1/status',
	OCCUSPACE_API_URL: 'https://api.ucsd.edu:8243/occuspace/v1.0',
	MOBILE_API_AUTH_URL: 'https://api.ucsd.edu:8243/token',
	MY_STUDENT_CONTACT_API_URL: 'https://api.ucsd.edu:8243/student/my/student_contact_info/v1',
	MY_STUDENT_PROFILE_API_URL: 'https://api.ucsd.edu:8243/student/my/v1',

	/* RESOURCES */
	WEATHER_ICON_BASE_URL: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/v1/weather-icons/',

	/* LINKS */
	SHUTTLE_SCHEDULE_URL: 'https://transportation.ucsd.edu/shuttles/',
	PRIVACY_POLICY_URL: 'https://mobile.ucsd.edu/privacy-policy.html',
	ACCOUNT_HELP_URL: 'https://acms.ucsd.edu/students/accounts-and-passwords/index.html',

	/* TTLs */
	LOCATION_TTL: 15000, // 15 seconds
	SHUTTLE_API_TTL: 15000, // 15 seconds
	DATA_SAGA_TTL: 60000, // 60 seconds
	PARKING_API_TTL: 300000,	// 5 minutes
	SCHEDULE_TTL: 1800000, // 30 minutes
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
	SID_API_TTL: 86400000, // 1 day

	/* TIMEOUTS */
	HTTP_REQUEST_TTL: 15000, // 15 seconds
	SID_CARD_TIMEOUT: 30000, // 30 seconds
	SSO_TTL: 20000, // 20 seconds
	MESSAGING_TTL: 15000, // 15 seconds
	PUBLIC_MOBILE_AUTH_TIMEOUT: 15000, // 15 seconds
	OCCUSPACE_FETCH_TIMEOUT: 15000, // 15 seconds

	/* RETRIES */
	SSO_IDP_ERROR_RETRY_INCREMENT: 10000, // 10 seconds
	SSO_REFRESH_MAX_RETRIES: 3,
	MOBILE_PUBLIC_TOKEN_MAX_RETRIES: 3,
	SSO_REFRESH_RETRY_INCREMENT: 5000, // 5 seconds
	MOBILE_PUBLIC_TOKEN_RETRY_INCREMENT: 5000, // 5 seconds
	SSO_REFRESH_RETRY_MULTIPLIER: 3, // Multiplies increment by this amount for next try
	MOBILE_PUBLIC_TOKEN_RETRY_MULTIPLIER: 3, // Multiplies increment by this amount for next try

	/* UCSD AFFILIATION */
	UCSD_STUDENT: /(B|G|J|M|U)/
}