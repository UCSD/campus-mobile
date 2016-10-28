const AppSettings = require('../AppSettings');
const GoogleAnalytics = require('react-native-google-analytics-bridge');

GoogleAnalytics.setTrackerId(AppSettings.GOOGLE_ANALYTICS_ID);

module.exports = {

	log(msg) {
		if (AppSettings.DEBUG_ENABLED) {
			console.log(msg);
		}
	},

	error(msg) {
		if (AppSettings.DEBUG_ENABLED) {
			console.error(msg);
		}
	},

	ga(msg) {
		this.log(msg);
		GoogleAnalytics.trackScreenView(msg);
	},

};
