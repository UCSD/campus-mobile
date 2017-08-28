1) Create a folder in your home directory ".campusapp"

2) In your ".campusapp" folder, create a file "env.js" with the following content:

// Modify These Values
var APP_NAME = 'your-app-name';
var CODEPUSH_IOS_KEY_PROD = 'iOS Production Key Here';
var CODEPUSH_IOS_KEY_STG = 'iOS Staging Key Here';
var CODEPUSH_ANDROID_KEY_PROD = 'Android Production Key Here';
var CODEPUSH_ANDROID_KEY_STG = 'Android Staging Key Here';
var GOOGLE_ANALYTICS_ID = 'Google Analytics ID Here';
var GOOGLE_MAPS_API_KEY = 'Google Maps API Key Here';
var FIREBASE_KEY = 'FireBase API Key Here';

// Placeholder Values (Do Not Modify)
var APP_NAME_PH = 'Campus Mobile';
var CODEPUSH_IOS_KEY_PH = 'CODEPUSH_IOS_KEY_PH';
var CODEPUSH_ANDROID_KEY_PH = 'CODEPUSH_ANDROID_KEY_PH';
var GOOGLE_ANALYTICS_ID_PH = 'GOOGLE_ANALYTICS_ID_PH';
var GOOGLE_MAPS_API_KEY_PH = 'GOOGLE_MAPS_API_KEY_PH';
var FIREBASE_KEY_PH = 'FIREBASE_KEY_PH';

// Exports (Do Not Modify)
exports.APP_NAME = APP_NAME;
exports.APP_NAME_PH = APP_NAME_PH;
exports.CODEPUSH_IOS_KEY_PROD = CODEPUSH_IOS_KEY_PROD;
exports.CODEPUSH_IOS_KEY_STG = CODEPUSH_IOS_KEY_STG;
exports.CODEPUSH_IOS_KEY_PH = CODEPUSH_IOS_KEY_PH;
exports.CODEPUSH_ANDROID_KEY_PROD = CODEPUSH_ANDROID_KEY_PROD;
exports.CODEPUSH_ANDROID_KEY_STG = CODEPUSH_ANDROID_KEY_STG;
exports.CODEPUSH_ANDROID_KEY_PH = CODEPUSH_ANDROID_KEY_PH;
exports.GOOGLE_ANALYTICS_ID = GOOGLE_ANALYTICS_ID;
exports.GOOGLE_MAPS_API_KEY = GOOGLE_MAPS_API_KEY;
exports.GOOGLE_ANALYTICS_ID_PH = GOOGLE_ANALYTICS_ID_PH;
exports.GOOGLE_MAPS_API_KEY_PH = GOOGLE_MAPS_API_KEY_PH;
exports.FIREBASE_KEY = FIREBASE_KEY;
exports.FIREBASE_KEY_PH = FIREBASE_KEY_PH;
