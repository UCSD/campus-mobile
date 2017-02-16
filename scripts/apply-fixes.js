/* 	
	Usage:
	npm run-script apply-fixes
*/
const fs = require('fs');

const GA_BRIDGE_FIX_PATH = './node_modules/react-native-google-analytics-bridge/android/build.gradle';
const CORE_FIX_PATH = './node_modules/react-native/Libraries/Core/InitializeCore.js';
const GA_BRIDGE_ERR = 'com.google.android.gms:play-services-analytics:+';
const GA_BRIDGE_FIX = 'com.google.android.gms:play-services-analytics:9.4.0';
const CORE_ERR = 'function handleError(e, isFatal)';
const CORE_FIX = 'var handleError = function(e, isFatal)';

makeReplacements(GA_BRIDGE_FIX_PATH, [
	{ gaInitial: GA_BRIDGE_ERR, gaFixed: GA_BRIDGE_FIX }
]);

makeReplacements(CORE_FIX_PATH, [
	{ gaInitial: CORE_ERR, gaFixed: CORE_FIX }
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
