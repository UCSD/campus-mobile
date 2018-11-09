/*
	Usage:
	npm run-script [campus-prod|campus-qa]
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
	APP_NAME_PH: 'Campus Mobile',
	GOOGLE_ANALYTICS_ID_PH: 'GOOGLE_ANALYTICS_ID_PH',
	GOOGLE_MAPS_API_KEY_PH: 'GOOGLE_MAPS_API_KEY_PH',
	FIREBASE_KEY_PH: 'FIREBASE_KEY_PH',
	BUGSNAG_KEY_PH: 'BUGSNAG_KEY_PH',
	AUTH_SERVICE_API_KEY_PH: 'AUTH_SERVICE_API_KEY_PH',
	GS_PROJECT_ID_PH: 'GS_PROJECT_ID_PH',
	GS_STORAGE_BUCKET_PH: 'GS_STORAGE_BUCKET_PH',
	GS_FIREBASE_URL_PH: 'GS_FIREBASE_URL_PH',
	GS_PROJECT_NUMBER_PH: 'GS_PROJECT_NUMBER_PH', // iOS: GCM_SENDER_ID, Android: project_info.project_number
	GS_IOS_CLIENT_ID_PH: 'GS_IOS_CLIENT_ID_PH',
	GS_IOS_REVERSED_CLIENT_ID_PH: 'GS_IOS_REVERSED_CLIENT_ID_PH',
	GS_IOS_API_KEY_PH: 'GS_IOS_API_KEY_PH',
	GS_IOS_BUNDLE_ID_PH: 'GS_IOS_BUNDLE_ID_PH',
	GS_IOS_STORAGE_BUCKET_PH: 'GS_IOS_STORAGE_BUCKET_PH',
	GS_IOS_APP_ID_PH: '1:1:ios:1',
	GS_ANDROID_CLIENT_ID_PH: 'GS_ANDROID_CLIENT_ID_PH',
	GS_ANDROID_API_KEY_PH: 'GS_ANDROID_API_KEY_PH',
	GS_ANDROID_APP_ID_PH: 'GS_ANDROID_APP_ID_PH',
	GS_ANDROID_BUNDLE_ID_PH: 'GS_ANDROID_BUNDLE_ID_PH',
}

if (REPLACEMENT_ENV === 'prod' || REPLACEMENT_ENV === 'qa') {
	// AppSettings.js
	makeReplacements(APP_SETTINGS_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.APP_NAME, qaVal: myEnv.APP_NAME, phVal: PH.APP_NAME_PH },
		{ prodVal: myEnv.GOOGLE_ANALYTICS_ID_PROD, qaVal: myEnv.GOOGLE_ANALYTICS_ID_QA, phVal: PH.GOOGLE_ANALYTICS_ID_PH },
	])

	// ssoService.js
	makeReplacements(SSO_SERVICE_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.AUTH_SERVICE_API_KEY_PROD, qaVal: myEnv.AUTH_SERVICE_API_KEY_QA, phVal: PH.AUTH_SERVICE_API_KEY_PH },
	])

	// Info.plist
	makeReplacements(IOS_INFO_PLIST_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.APP_NAME, qaVal: myEnv.APP_NAME, phVal: PH.APP_NAME_PH },
		{ prodVal: myEnv.BUGSNAG_KEY, qaVal: myEnv.BUGSNAG_KEY, phVal: PH.BUGSNAG_KEY_PH }
	])

	// strings.xml
	makeReplacements(ANDROID_STRINGS_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.APP_NAME, qaVal: myEnv.APP_NAME, phVal: PH.APP_NAME_PH },
	])

	// AndroidManifest.xml
	makeReplacements(ANDROID_MANIFEST_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.GOOGLE_MAPS_API_KEY, qaVal: myEnv.GOOGLE_MAPS_API_KEY, phVal: PH.GOOGLE_MAPS_API_KEY_PH },
		{ prodVal: myEnv.BUGSNAG_KEY, qaVal: myEnv.BUGSNAG_KEY, phVal: PH.BUGSNAG_KEY_PH }
	])

	// GoogleService-Info.plist
	makeReplacements(IOS_GOOGLE_SERVICES_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.GS_IOS_PROD_CLIENT_ID, 				qaVal: myEnv.GS_IOS_QA_CLIENT_ID, 				phVal: PH.GS_IOS_CLIENT_ID_PH },
		{ prodVal: myEnv.GS_IOS_PROD_REVERSED_CLIENT_ID,		qaVal: myEnv.GS_IOS_QA_REVERSED_CLIENT_ID, 		phVal: PH.GS_IOS_REVERSED_CLIENT_ID_PH },
		{ prodVal: myEnv.GS_IOS_PROD_API_KEY, 					qaVal: myEnv.GS_IOS_QA_API_KEY, 				phVal: PH.GS_IOS_API_KEY_PH },
		{ prodVal: myEnv.GS_IOS_BUNDLE_ID, 						qaVal: myEnv.GS_IOS_BUNDLE_ID, 					phVal: PH.GS_IOS_BUNDLE_ID_PH },
		{ prodVal: myEnv.GS_IOS_PROD_APP_ID, 					qaVal: myEnv.GS_IOS_QA_APP_ID, 					phVal: PH.GS_IOS_APP_ID_PH },
		{ prodVal: myEnv.GS_PROD_FIREBASE_URL, 					qaVal: myEnv.GS_QA_FIREBASE_URL, 				phVal: PH.GS_FIREBASE_URL_PH },
		{ prodVal: myEnv.GS_PROD_STORAGE_BUCKET, 				qaVal: myEnv.GS_QA_STORAGE_BUCKET, 				phVal: PH.GS_STORAGE_BUCKET_PH },
		{ prodVal: myEnv.GS_PROD_PROJECT_ID, 					qaVal: myEnv.GS_QA_PROJECT_ID, 					phVal: PH.GS_PROJECT_ID_PH },
		{ prodVal: myEnv.GS_PROD_PROJECT_NUMBER, 				qaVal: myEnv.GS_QA_PROJECT_NUMBER, 				phVal: PH.GS_PROJECT_NUMBER_PH },
	])

	// google-services.json
	makeReplacements(ANDROID_GOOGLE_SERVICES_PATH, REPLACEMENT_ENV, [
		{ prodVal: myEnv.GS_ANDROID_PROD_CLIENT_ID, 			qaVal: myEnv.GS_ANDROID_QA_CLIENT_ID, 			phVal: PH.GS_ANDROID_CLIENT_ID_PH },
		{ prodVal: myEnv.GS_ANDROID_PROD_API_KEY, 				qaVal: myEnv.GS_ANDROID_QA_API_KEY, 			phVal: PH.GS_ANDROID_API_KEY_PH },
		{ prodVal: myEnv.GS_ANDROID_PROD_APP_ID, 				qaVal: myEnv.GS_ANDROID_QA_APP_ID, 				phVal: PH.GS_ANDROID_APP_ID_PH },
		{ prodVal: myEnv.GS_ANDROID_BUNDLE_ID, 					qaVal: myEnv.GS_ANDROID_BUNDLE_ID, 				phVal: PH.GS_ANDROID_BUNDLE_ID_PH },
		{ prodVal: myEnv.GS_PROD_FIREBASE_URL, 					qaVal: myEnv.GS_QA_FIREBASE_URL, 				phVal: PH.GS_FIREBASE_URL_PH },
		{ prodVal: myEnv.GS_PROD_STORAGE_BUCKET, 				qaVal: myEnv.GS_QA_STORAGE_BUCKET, 				phVal: PH.GS_STORAGE_BUCKET_PH },
		{ prodVal: myEnv.GS_PROD_PROJECT_ID, 					qaVal: myEnv.GS_QA_PROJECT_ID, 					phVal: PH.GS_PROJECT_ID_PH },
		{ prodVal: myEnv.GS_PROD_PROJECT_NUMBER, 				qaVal: myEnv.GS_QA_PROJECT_NUMBER, 				phVal: PH.GS_PROJECT_NUMBER_PH },
	])
} else {
	console.log('Error: Replacement type not specififed.\nSample Usage: npm run-script [campus-prod|campus-qa]')
}


function makeReplacements(FILE_PATH, ENV, REPLACEMENTS) {
	fs.readFile(FILE_PATH, 'utf8', (err, data) => {
		if (!err) {
			for (let i = 0; REPLACEMENTS.length > i; i++) {
				if (ENV === 'prod') {
					data = data.replace(REPLACEMENTS[i].phVal, REPLACEMENTS[i].prodVal)
				} else if (ENV === 'qa') {
					data = data.replace(REPLACEMENTS[i].phVal, REPLACEMENTS[i].qaVal)
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
