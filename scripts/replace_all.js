/*
	Usage:
	npm run-script [campus-prod|campus-qa|campus-ph]
*/
const fs = require('fs')
const os = require('os')

const REPLACEMENT_ENV = process.argv[2]
const ENV_TYPE = process.argv[3]

// Environment Setup
let myEnv
if (ENV_TYPE === 'ci') {
	myEnv = process.env
} else {
	myEnv = require(os.homedir() + '/.campusmobile/env.js') // eslint-disable-line
}

// File Paths
const APP_SETTINGS_PATH = './app/AppSettings.js',
	SSO_SERVICE_PATH = './app/services/ssoService.js',
	IOS_INFO_PLIST_PATH = './ios/CampusMobile/Info.plist',
	ANDROID_STRINGS_PATH = './android/app/src/main/res/values/strings.xml',
	ANDROID_MANIFEST_PATH = './android/app/src/main/AndroidManifest.xml',
	IOS_GOOGLE_SERVICES_PATH = './ios/GoogleService-Info.plist',
	ANDROID_GOOGLE_SERVICES_PATH = './android/app/google-services.json'

// Placeholder Values
const PH = {
	APP_NAME_PH: 'APP_NAME_PH',
	GOOGLE_ANALYTICS_ID_PH: 'GOOGLE_ANALYTICS_ID_PH',
	GOOGLE_MAPS_API_KEY_PH: 'GOOGLE_MAPS_API_KEY_PH',
	FIREBASE_KEY_PH: 'FIREBASE_KEY_PH',
	BUGSNAG_KEY_PH: 'BUGSNAG_KEY_PH',
	AUTH_SERVICE_API_KEY_PH: 'AUTH_SERVICE_API_KEY_PH',
}

if (REPLACEMENT_ENV === 'prod' || REPLACEMENT_ENV === 'qa' || REPLACEMENT_ENV === 'ph') {
	// AppSettings.js
	makeReplacements(APP_SETTINGS_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.APP_NAME, stgVal: myEnv.APP_NAME, phVal: PH.APP_NAME_PH },
		{ prodVal: myEnv.GOOGLE_ANALYTICS_ID_PROD, stgVal: myEnv.GOOGLE_ANALYTICS_ID_PH, phVal: PH.GOOGLE_ANALYTICS_ID_PH },
	])

	// ssoService.js
	makeReplacements(SSO_SERVICE_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.AUTH_SERVICE_API_KEY_PROD, stgVal: myEnv.AUTH_SERVICE_API_KEY_QA, phVal: PH.AUTH_SERVICE_API_KEY_PH },
	])

	// Info.plist
	makeReplacements(IOS_INFO_PLIST_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.APP_NAME, stgVal: myEnv.APP_NAME, phVal: PH.APP_NAME_PH },
		{ prodVal: myEnv.BUGSNAG_KEY, stgVal: myEnv.BUGSNAG_KEY, phVal: PH.BUGSNAG_KEY_PH }
	])

	// strings.xml
	makeReplacements(ANDROID_STRINGS_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.APP_NAME, stgVal: myEnv.APP_NAME, phVal: PH.APP_NAME_PH },
	])

	// AndroidManifest.xml
	makeReplacements(ANDROID_MANIFEST_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.GOOGLE_MAPS_API_KEY, stgVal: myEnv.GOOGLE_MAPS_API_KEY, phVal: PH.GOOGLE_MAPS_API_KEY_PH },
		{ prodVal: myEnv.BUGSNAG_KEY, stgVal: myEnv.BUGSNAG_KEY, phVal: PH.BUGSNAG_KEY_PH }
	])
/*
	// GoogleService-Info.plist
	makeReplacements(IOS_GOOGLE_SERVICES_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.FIREBASE_IOS_KEY, phVal: PH.FIREBASE_KEY_PH },
	])

	// google-services.json
	makeReplacements(ANDROID_GOOGLE_SERVICES_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.FIREBASE_ANDROID_KEY, phVal: PH.FIREBASE_KEY_PH },
	])
*/
} else {
	console.log('Error: Replacement type not specififed')
	console.log('Sample Usage: npm run-script [campus-ph|campus-qa|campus-prod]')
}


function makeReplacements(FILE_PATH, ENV, REPLACEMENTS) {
	fs.readFile(FILE_PATH, 'utf8', (err, data) => {
		if (!err) {
			for (let i = 0; REPLACEMENTS.length > i; i++) {
				if (ENV === 'prod') {
					data = data.replace(REPLACEMENTS[i].phVal, REPLACEMENTS[i].prodVal).replace(REPLACEMENTS[i].stgVal, REPLACEMENTS[i].prodVal)
				} else if (ENV === 'qa') {
					data = data.replace(REPLACEMENTS[i].prodVal, REPLACEMENTS[i].stgVal).replace(REPLACEMENTS[i].phVal, REPLACEMENTS[i].stgVal)
				} else if (ENV === 'ph') {
					data = data.replace(REPLACEMENTS[i].prodVal, REPLACEMENTS[i].phVal).replace(REPLACEMENTS[i].stgVal, REPLACEMENTS[i].phVal)
				}
			}
			fs.writeFile(FILE_PATH, data, 'utf8', (writeErr) => {
				if (writeErr) {
					return console.log(err)
				} else {
					console.log('SUCCESS: File ' + FILE_PATH + ' updated with ' + ENV + ' values.')
				}
			})
		} else {
			return console.log('Error: ' + err)
		}
	})
}
