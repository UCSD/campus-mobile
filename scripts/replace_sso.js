/*
 *	Usage:
 *	npm run-script [insert-sso-api-key|insert-sso-api-key-ph]
 */
var fs = require('fs');
var os = require('os');

var REPLACEMENT_TYPE = process.argv[2];
var ENV_TYPE = process.argv[3];
var myEnv = require(os.homedir() + '/.campusmobile/env.js');

var SSO_SERVICE_PATH = './app/services/ssoService.js';

var AUTH_SERVICE_API_KEY = myEnv.AUTH_SERVICE_API_KEY;
var AUTH_SERVICE_API_KEY_PH = myEnv.AUTH_SERVICE_API_KEY_PH;

if (REPLACEMENT_TYPE === 'production' || REPLACEMENT_TYPE === 'placeholder') {
	// ssoService.js
	makeReplacements(SSO_SERVICE_PATH, REPLACEMENT_TYPE, [
		{ prodVal: AUTH_SERVICE_API_KEY, phVal: AUTH_SERVICE_API_KEY_PH },
	]);
} else {
	console.log('Error: Replacement type not specififed');
	console.log('Sample Usage: npm run-script [insert-sso-api-key|insert-sso-api-key-ph]');
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
