/* 	
	Usage:
	npm run-script insert-production-values
	npm run-script insert-staging-values
	npm run-script insert-placeholder-values
*/
var fs = require('fs');
var REPLACEMENT_TYPE = process.argv[2];
var myEnv = require(getUserHome() + '/.campusapp/env.js');

var APP_SETTINGS_PATH = './app/AppSettings.js';
var IOS_INFO_PLIST_PATH = './ios/CampusMobile/Info.plist';
var ANDROID_STRINGS_PATH = './android/app/src/main/res/values/strings.xml';
var ANDROID_MANIFEST_PATH = './android/app/src/main/AndroidManifest.xml';

var APP_NAME = myEnv.APP_NAME;
var APP_NAME_PH = myEnv.APP_NAME_PH;

var GOOGLE_ANALYTICS_ID = myEnv.GOOGLE_ANALYTICS_ID;
var GOOGLE_ANALYTICS_ID_PH = myEnv.GOOGLE_ANALYTICS_ID_PH;

var CODEPUSH_IOS_KEY_PROD = myEnv.CODEPUSH_IOS_KEY_PROD;
var CODEPUSH_IOS_KEY_STG = myEnv.CODEPUSH_IOS_KEY_STG;
var CODEPUSH_IOS_KEY_PH = myEnv.CODEPUSH_IOS_KEY_PH;
var CODEPUSH_ANDROID_KEY_PROD = myEnv.CODEPUSH_ANDROID_KEY_PROD;
var CODEPUSH_ANDROID_KEY_STG = myEnv.CODEPUSH_ANDROID_KEY_STG;
var CODEPUSH_ANDROID_KEY_PH = myEnv.CODEPUSH_ANDROID_KEY_PH;

var GOOGLE_MAPS_API_KEY = myEnv.GOOGLE_MAPS_API_KEY;
var GOOGLE_MAPS_API_KEY_PH = myEnv.GOOGLE_MAPS_API_KEY_PH;

if (REPLACEMENT_TYPE === 'production' || REPLACEMENT_TYPE === 'staging' || REPLACEMENT_TYPE === 'placeholder') {
	// AppSettings.js
	makeReplacements(APP_SETTINGS_PATH, REPLACEMENT_TYPE, [
		{ prodVal: APP_NAME, stgVal: APP_NAME, phVal: APP_NAME_PH },
		{ prodVal: GOOGLE_ANALYTICS_ID, stgVal: GOOGLE_ANALYTICS_ID, phVal: GOOGLE_ANALYTICS_ID_PH },
	]);
	// Info.plist
	makeReplacements(IOS_INFO_PLIST_PATH, REPLACEMENT_TYPE, [
		{ prodVal: APP_NAME, stgVal: APP_NAME, phVal: APP_NAME_PH },
		{ prodVal: CODEPUSH_IOS_KEY_PROD, stgVal: CODEPUSH_IOS_KEY_STG, phVal: CODEPUSH_IOS_KEY_PH },
	]);

	// strings.xml
	makeReplacements(ANDROID_STRINGS_PATH, REPLACEMENT_TYPE, [
		{ prodVal: APP_NAME, stgVal: APP_NAME, phVal: APP_NAME_PH },
		{ prodVal: CODEPUSH_ANDROID_KEY_PROD, stgVal: CODEPUSH_ANDROID_KEY_STG, phVal: CODEPUSH_ANDROID_KEY_PH },
	]);

	// AndroidManifest.xml
	makeReplacements(ANDROID_MANIFEST_PATH, REPLACEMENT_TYPE, [
		{ prodVal: GOOGLE_MAPS_API_KEY, stgVal: GOOGLE_MAPS_API_KEY, phVal: GOOGLE_MAPS_API_KEY_PH },
	]);
} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: replace_all.js [Production|Staging|Placeholder]');
}


function makeReplacements(FILE_PATH, REPLACEMENT_TYPE, REPLACEMENTS) {
	fs.readFile(FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			for (var i = 0; REPLACEMENTS.length > i; i++) {
				if (REPLACEMENT_TYPE === 'production') {
					data = data.replace(REPLACEMENTS[i].phVal, REPLACEMENTS[i].prodVal).replace(REPLACEMENTS[i].stgVal, REPLACEMENTS[i].prodVal);
				} else if (REPLACEMENT_TYPE === 'staging') {
					data = data.replace(REPLACEMENTS[i].prodVal, REPLACEMENTS[i].stgVal).replace(REPLACEMENTS[i].phVal, REPLACEMENTS[i].stgVal);
				} else if (REPLACEMENT_TYPE === 'placeholder') {
					data = data.replace(REPLACEMENTS[i].prodVal, REPLACEMENTS[i].phVal).replace(REPLACEMENTS[i].stgVal, REPLACEMENTS[i].phVal);
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

function getUserHome() {
	return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
}
