1) Create a folder in your home directory ".campusmobile"

2) In your ".campusmobile" folder, create a file "env.js" with the following content:

```module.exports = {

	/* PROD & QA */
	
	APP_NAME: 'Your App Name',
	GOOGLE_MAPS_API_KEY: 'Your Google Maps API Key',
	GS_IOS_BUNDLE_ID: 'Your IOS Bundle ID',
	GS_ANDROID_BUNDLE_ID: 'Your Android Bundle ID',
	BUGSNAG_KEY: 'Your Bugsnag Key',

	/* PROD ONLY */
	GOOGLE_ANALYTICS_ID_PROD: 'Your PROD Google Analytics ID',
	AUTH_SERVICE_API_KEY_PROD: 'Your PROD Auth Service API Key',
	GS_PROD_PROJECT_ID: 'Your PROD Google Services Project ID',
	GS_PROD_STORAGE_BUCKET: 'Your PROD Google Services Storage Bucket',
	GS_PROD_FIREBASE_URL: 'Your PROD Firebase URL',
	GS_PROD_PROJECT_NUMBER: 'Your PROD Google Services Project Number',
	GS_IOS_PROD_CLIENT_ID: 'Your PROD Google Services IOS Client ID',
	GS_IOS_PROD_REVERSED_CLIENT_ID: 'Your PROD Google Services Reversed Client ID',
	GS_IOS_PROD_API_KEY: 'Your PROD Google Services IOS API Key',
	GS_IOS_PROD_APP_ID: 'Your PROD Google Services App ID',
	GS_ANDROID_PROD_CLIENT_ID: 'Your PROD Google Services Android Client ID',
	GS_ANDROID_PROD_API_KEY: 'Your PROD Google Services Android API Key',
	GS_ANDROID_PROD_APP_ID: 'Your PROD Google Services App ID',

	/* QA ONLY */
	GOOGLE_ANALYTICS_ID_QA: 'Your QA Google Analytics ID',
	AUTH_SERVICE_API_KEY_QA: 'Your QA Auth Service API Key',
	GS_QA_PROJECT_ID: 'Your QA Google Services Project ID',
	GS_QA_STORAGE_BUCKET: 'Your QA Google Services Storage Bucket',
	GS_QA_FIREBASE_URL: 'Your QA Firebase URL',
	GS_QA_PROJECT_NUMBER: 'Your QA Google Services Project Number',
	GS_IOS_QA_CLIENT_ID: 'Your QA Google Services IOS Client ID',
	GS_IOS_QA_REVERSED_CLIENT_ID: 'Your QA Google Services Reversed Client ID',
	GS_IOS_QA_API_KEY: 'Your QA Google Services IOS API Key',
	GS_IOS_QA_APP_ID: 'Your QA Google Services App ID',
	GS_ANDROID_QA_CLIENT_ID: 'Your QA Google Services Android Client ID',
	GS_ANDROID_QA_API_KEY: 'Your QA Google Services Android API Key',
	GS_ANDROID_QA_APP_ID: 'Your QA Google Services App ID',

}```

3. Insert QA or PROD values into your application via `npm run-script campus-qa` or `npm run-script campus-prod`
