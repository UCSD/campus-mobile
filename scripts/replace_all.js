/* 	
	Usage:
	npm run-script insert-production-values
	npm run-script insert-placeholder-values
*/
var fs = require('fs');
var os = require('os');
var REPLACEMENT_TYPE = process.argv[2];
var ENV_TYPE = process.argv[3];

var myEnv;
if (ENV_TYPE === 'ci') {
	myEnv = process.env;
} else {
	var myEnv = require(os.homedir() + '/.campusmobile/env.js');
}

var APP_SETTINGS_PATH = './app/AppSettings.js';
var SSO_SERVICE_PATH = './app/services/ssoService.js';

var IOS_INFO_PLIST_PATH = './ios/CampusMobile/Info.plist';

var ANDROID_STRINGS_PATH = './android/app/src/main/res/values/strings.xml';
var ANDROID_MANIFEST_PATH = './android/app/src/main/AndroidManifest.xml';

var IOS_GOOGLE_SERVICES_PATH = './ios/GoogleService-Info.plist';
var ANDROID_GOOGLE_SERVICES_PATH = './android/app/google-services.json';

var APP_NAME = myEnv.APP_NAME;
var APP_NAME_PH = myEnv.APP_NAME_PH;

var AUTH_SERVICE_API_KEY = myEnv.AUTH_SERVICE_API_KEY;
var AUTH_SERVICE_API_KEY_PH = myEnv.AUTH_SERVICE_API_KEY_PH;

var GOOGLE_ANALYTICS_ID = myEnv.GOOGLE_ANALYTICS_ID;
var GOOGLE_ANALYTICS_ID_PH = myEnv.GOOGLE_ANALYTICS_ID_PH;

var GOOGLE_MAPS_API_KEY = myEnv.GOOGLE_MAPS_API_KEY;
var GOOGLE_MAPS_API_KEY_PH = myEnv.GOOGLE_MAPS_API_KEY_PH;

var FIREBASE_IOS_KEY = myEnv.FIREBASE_IOS_KEY;
var FIREBASE_ANDROID_KEY = myEnv.FIREBASE_ANDROID_KEY;
var FIREBASE_KEY_PH = myEnv.FIREBASE_KEY_PH;

if (REPLACEMENT_TYPE === 'production' || REPLACEMENT_TYPE === 'placeholder') {
	// AppSettings.js
	makeReplacements(APP_SETTINGS_PATH, REPLACEMENT_TYPE, [
		{ prodVal: APP_NAME, phVal: APP_NAME_PH },
		{ prodVal: GOOGLE_ANALYTICS_ID, phVal: GOOGLE_ANALYTICS_ID_PH },
	]);

	// ssoService.js
	makeReplacements(SSO_SERVICE_PATH, REPLACEMENT_TYPE, [
		{ prodVal: AUTH_SERVICE_API_KEY, phVal: AUTH_SERVICE_API_KEY_PH },
	]);

	// Info.plist
	makeReplacements(IOS_INFO_PLIST_PATH, REPLACEMENT_TYPE, [
		{ prodVal: APP_NAME, phVal: APP_NAME_PH },
	]);

	// strings.xml
	makeReplacements(ANDROID_STRINGS_PATH, REPLACEMENT_TYPE, [
		{ prodVal: APP_NAME, phVal: APP_NAME_PH },
	]);

	// AndroidManifest.xml
	makeReplacements(ANDROID_MANIFEST_PATH, REPLACEMENT_TYPE, [
		{ prodVal: GOOGLE_MAPS_API_KEY, phVal: GOOGLE_MAPS_API_KEY_PH },
	]);

	// GoogleService-Info.plist
	makeReplacements(IOS_GOOGLE_SERVICES_PATH, REPLACEMENT_TYPE, [
		{ prodVal: FIREBASE_IOS_KEY, phVal: FIREBASE_KEY_PH },
	]);

	// google-services.json
	makeReplacements(ANDROID_GOOGLE_SERVICES_PATH, REPLACEMENT_TYPE, [
		{ prodVal: FIREBASE_ANDROID_KEY, phVal: FIREBASE_KEY_PH },
	]);

} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: npm run-script [insert-production-values|insert-placeholder-values]');
}


function makeReplacements(FILE_PATH, REPLACEMENT_TYPE, REPLACEMENTS) {
	fs.readFile(FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			for (var i = 0; REPLACEMENTS.length > i; i++) {
				if (REPLACEMENT_TYPE === 'production') {
					data = data.replace(REPLACEMENTS[i].phVal, REPLACEMENTS[i].prodVal);
				} else if (REPLACEMENT_TYPE === 'placeholder') {
					data = data.replace(REPLACEMENTS[i].prodVal, REPLACEMENTS[i].phVal);
				}
			}
			fs.writeFile(FILE_PATH, data, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + FILE_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});
}
