/* 	
	Usage:
	npm run-script apply-fixes
*/
const fs = require('fs');

const MAPS_FIX_PATH = './node_modules/react-native-maps/android/build.gradle';
const MAPS_ERR = "9.8.0";
const MAPS_FIX = "+";

const CORE_FIX_PATH = './node_modules/react-native/Libraries/Core/InitializeCore.js';
const CORE_ERR = "function handleError\\(e, isFatal\\)";
const CORE_FIX = "var handleError = function(e, isFatal)";

makeReplacements(MAPS_FIX_PATH, [
	{ initial: MAPS_ERR, fixed: MAPS_FIX }
]);

makeReplacements(CORE_FIX_PATH, [
	{ initial: CORE_ERR, fixed: CORE_FIX }
]);

function makeReplacements(FILE_PATH, REPLACEMENTS) {
	fs.readFile(FILE_PATH, 'utf8', function(err, data) {
		if (err) {
			return console.log(err);
		} else {

			for (var i = 0; REPLACEMENTS.length > i; i++) {
				data = data.replace(new RegExp(REPLACEMENTS[i].initial, 'g'), REPLACEMENTS[i].fixed);
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
