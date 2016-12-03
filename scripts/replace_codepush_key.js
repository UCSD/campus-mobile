// Usage: replace_codepush_key.js [Production|Staging|Placeholder]

var REPLACEMENT_TYPE = process.argv[2];

var fs = require('fs');
var myEnv = require(getUserHome() + '/.nowapp/env.js');

var ANDROID_FILE_PATH = '../android/app/src/main/res/values/strings.xml';
var IOS_FILE_PATH = '../ios/nowucsandiego/Info.plist';

var CODEPUSH_IOS_KEY_PROD = myEnv.CODEPUSH_IOS_KEY_PROD;
var CODEPUSH_IOS_KEY_STG = myEnv.CODEPUSH_IOS_KEY_STG;
var CODEPUSH_IOS_KEY_PH = myEnv.CODEPUSH_IOS_KEY_PH;

var CODEPUSH_ANDROID_KEY_PROD = myEnv.CODEPUSH_ANDROID_KEY_PROD;
var CODEPUSH_ANDROID_KEY_STG = myEnv.CODEPUSH_ANDROID_KEY_STG;
var CODEPUSH_ANDROID_KEY_PH = myEnv.CODEPUSH_ANDROID_KEY_PH;

if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging' || REPLACEMENT_TYPE === 'Placeholder') {

	// iOS
	fs.readFile(IOS_FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			var result;

			if (REPLACEMENT_TYPE === 'Production') {
				result = data.replace(CODEPUSH_IOS_KEY_PH, CODEPUSH_IOS_KEY_PROD).replace(CODEPUSH_IOS_KEY_STG, CODEPUSH_IOS_KEY_PROD);
			} else if (REPLACEMENT_TYPE === 'Staging') {
				result = data.replace(CODEPUSH_IOS_KEY_PH, CODEPUSH_IOS_KEY_STG).replace(CODEPUSH_IOS_KEY_PROD, CODEPUSH_IOS_KEY_STG);
			} else if (REPLACEMENT_TYPE === 'Placeholder') {
				result = data.replace(CODEPUSH_IOS_KEY_STG, CODEPUSH_IOS_KEY_PH).replace(CODEPUSH_IOS_KEY_PROD, CODEPUSH_IOS_KEY_PH);
			}

			fs.writeFile(IOS_FILE_PATH, result, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + IOS_FILE_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});

	// Android
	fs.readFile(ANDROID_FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			var result;

			if (REPLACEMENT_TYPE === 'Production') {
				result = data.replace(CODEPUSH_ANDROID_KEY_PH, CODEPUSH_ANDROID_KEY_PROD).replace(CODEPUSH_ANDROID_KEY_STG, CODEPUSH_ANDROID_KEY_PROD);
			} else if (REPLACEMENT_TYPE === 'Staging') {
				result = data.replace(CODEPUSH_ANDROID_KEY_PH, CODEPUSH_ANDROID_KEY_STG).replace(CODEPUSH_ANDROID_KEY_PROD, CODEPUSH_ANDROID_KEY_STG);
			} else if (REPLACEMENT_TYPE === 'Placeholder') {
				result = data.replace(CODEPUSH_ANDROID_KEY_STG, CODEPUSH_ANDROID_KEY_PH).replace(CODEPUSH_ANDROID_KEY_PROD, CODEPUSH_ANDROID_KEY_PH);
			}

			fs.writeFile(ANDROID_FILE_PATH, result, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + ANDROID_FILE_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});

} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: replace_codepush_keys.js [replacement type]');
	console.log('Replacement Types: Production, Staging, Placeholder');
}

function getUserHome() {
	return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
}