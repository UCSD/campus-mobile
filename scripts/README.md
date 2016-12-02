1) Create a folder in your home directory ".nowapp"

2) In your ".nowapp" folder, create a file "env.js" with the following content:

	var APP_NAME = 'now-mobile';
	var APP_SHORTNAME = 'now-mobile';	// Text shown under your App Icon

	var CODEPUSH_IOS_KEY_PROD = 'iOS Production Key Here';
	var CODEPUSH_IOS_KEY_STG = 'iOS Staging Key Here';
	var CODEPUSH_ANDROID_KEY_STG = 'Android Staging Key Here';
	var CODEPUSH_ANDROID_KEY_PROD = 'Android Production Key Here';

	var GOOGLE_ANALYTICS_ID = 'Google Analytics ID Here';
	var GOOGLE_MAPS_API_KEY = '';


	exports.APP_NAME = APP_NAME;
	exports.APP_SHORTNAME = APP_SHORTNAME;

	exports.CODEPUSH_IOS_KEY_PROD = CODEPUSH_IOS_KEY_PROD;
	exports.CODEPUSH_IOS_KEY_STG = CODEPUSH_IOS_KEY_STG;
	exports.CODEPUSH_ANDROID_KEY_STG = CODEPUSH_ANDROID_KEY_STG;
	exports.CODEPUSH_ANDROID_KEY_PROD = CODEPUSH_ANDROID_KEY_PROD;

	exports.GOOGLE_ANALYTICS_ID = GOOGLE_ANALYTICS_ID;
	exports.GOOGLE_MAPS_API_KEY = GOOGLE_MAPS_API_KEY;
