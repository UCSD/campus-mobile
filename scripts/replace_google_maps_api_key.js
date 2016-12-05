// Usage: replace_google_maps_api_key.js [Production|Staging|Placeholder]

var REPLACEMENT_TYPE = process.argv[2];

var fs = require('fs');
var myEnv = require(getUserHome() + '/.nowapp/env.js');

var GOOGLE_MAPS_API_KEY_FILE_PATH = '../android/app/src/main/AndroidManifest.xml';

var GOOGLE_MAPS_API_KEY = myEnv.GOOGLE_MAPS_API_KEY;
var GOOGLE_MAPS_API_KEY_PH = myEnv.GOOGLE_MAPS_API_KEY_PH;

if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging' || REPLACEMENT_TYPE === 'Placeholder') {

	fs.readFile(GOOGLE_MAPS_API_KEY_FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			var result;

			if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging') {
				result = data.replace(GOOGLE_MAPS_API_KEY_PH, GOOGLE_MAPS_API_KEY);
			} else if (REPLACEMENT_TYPE === 'Placeholder') {
				result = data.replace(GOOGLE_MAPS_API_KEY, GOOGLE_MAPS_API_KEY_PH);
			}

			fs.writeFile(GOOGLE_MAPS_API_KEY_FILE_PATH, result, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + GOOGLE_MAPS_API_KEY_FILE_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});

} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: replace_google_maps_api_key.js [Production|Staging|Placeholder]');
}

function getUserHome() {
	return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
}