// Usage: replace_app_name.js [Production|Staging|Placeholder]

var REPLACEMENT_TYPE = process.argv[2];

var fs = require('fs');
var myEnv = require(getUserHome() + '/.nowapp/env.js');

var APP_SETTINGS_PATH = '../app/AppSettings.js';
var IOS_INFO_PLIST_PATH = '../ios/nowucsandiego/Info.plist';
var ANDROID_STRINGS_PATH = '../android/app/src/main/res/values/strings.xml';

var APP_NAME = myEnv.APP_NAME;
var APP_NAME_PH = myEnv.APP_NAME_PH;

var APP_CAMPUS_NAME = myEnv.APP_CAMPUS_NAME;
var APP_CAMPUS_NAME_PH = myEnv.APP_CAMPUS_NAME_PH;

var APP_SHORTNAME = myEnv.APP_SHORTNAME;
var APP_SHORTNAME_PH = myEnv.APP_SHORTNAME_PH;

if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging' || REPLACEMENT_TYPE === 'Placeholder') {

	fs.readFile(APP_SETTINGS_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			var result;
			if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging') {
				result = data.replace(APP_NAME_PH, APP_NAME).replace(APP_CAMPUS_NAME_PH, APP_CAMPUS_NAME);
			} else if (REPLACEMENT_TYPE === 'Placeholder') {
				result = data.replace(APP_NAME, APP_NAME_PH).replace(APP_CAMPUS_NAME, APP_CAMPUS_NAME_PH);
			}
			fs.writeFile(APP_SETTINGS_PATH, result, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + APP_SETTINGS_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});

	// iOS
	fs.readFile(IOS_INFO_PLIST_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			var result;
			if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging') {
				result = data.replace(APP_SHORTNAME_PH, APP_SHORTNAME);
			} else if (REPLACEMENT_TYPE === 'Placeholder') {
				result = data.replace(APP_SHORTNAME, APP_SHORTNAME_PH);
			}
			fs.writeFile(IOS_INFO_PLIST_PATH, result, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + IOS_INFO_PLIST_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});

	// Android
	fs.readFile(ANDROID_STRINGS_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			var result;
			if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging') {
				result = data.replace(APP_SHORTNAME_PH, APP_SHORTNAME);
			} else if (REPLACEMENT_TYPE === 'Placeholder') {
				result = data.replace(APP_SHORTNAME, APP_SHORTNAME_PH);
			}
			fs.writeFile(ANDROID_STRINGS_PATH, result, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + ANDROID_STRINGS_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});

} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: replace_app_name.js [Production|Staging|Placeholder]');
}

function getUserHome() {
	return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
}