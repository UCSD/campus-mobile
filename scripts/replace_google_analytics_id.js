// Usage: replace_codepush_key.js [Production|Staging|Placeholder]

var REPLACEMENT_TYPE = process.argv[2];

var fs = require('fs');
var myEnv = require(getUserHome() + '/.nowapp/env.js');

var GA_ID_FILE_PATH = '../app/AppSettings.js';

var GOOGLE_ANALYTICS_ID = myEnv.GOOGLE_ANALYTICS_ID;
var GOOGLE_ANALYTICS_ID_PH = myEnv.GOOGLE_ANALYTICS_ID_PH;

if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging' || REPLACEMENT_TYPE === 'Placeholder') {

	// iOS
	fs.readFile(GA_ID_FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {
			var result;

			if (REPLACEMENT_TYPE === 'Production' || REPLACEMENT_TYPE === 'Staging') {
				result = data.replace(GOOGLE_ANALYTICS_ID_PH, GOOGLE_ANALYTICS_ID);
			} else if (REPLACEMENT_TYPE === 'Placeholder') {
				result = data.replace(GOOGLE_ANALYTICS_ID, GOOGLE_ANALYTICS_ID_PH);
			}

			fs.writeFile(GA_ID_FILE_PATH, result, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + GA_ID_FILE_PATH + ' updated with ' + REPLACEMENT_TYPE + ' values.');
				}
			});
		}
	});

} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: replace_google_analytics_id.js [Production|Staging|Placeholder]');
}

function getUserHome() {
	return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
}