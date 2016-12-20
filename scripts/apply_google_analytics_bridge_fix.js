/* 	
	Usage:
	npm run-script apply-ga-bridge-fix
*/
var fs = require('fs');

var GA_BRIDGE_FIX_PATH = './node_modules/react-native-google-analytics-bridge/android/build.gradle';
var GA_BRIDGE_ERR = 'com.google.android.gms:play-services-analytics:+';
var GA_BRIDGE_FIX = 'com.google.android.gms:play-services-analytics:9.4.0';

// AppSettings.js
makeReplacements(GA_BRIDGE_FIX_PATH, [
	{ gaInitial: GA_BRIDGE_ERR, gaFixed: GA_BRIDGE_FIX },
]);


function makeReplacements(FILE_PATH, REPLACEMENTS) {
	fs.readFile(FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {

			for (var i = 0; REPLACEMENTS.length > i; i++) {
				data = data.replace(REPLACEMENTS[i].gaInitial, REPLACEMENTS[i].gaFixed);
			}

			fs.writeFile(FILE_PATH, data, 'utf8', function(err) {
				if (err) {
					return console.log(err);
				} else {
					console.log('SUCCESS: File ' + FILE_PATH + ' updated with fixed value.');
				}
			});
		}
	});
}

function getUserHome() {
	return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
}
