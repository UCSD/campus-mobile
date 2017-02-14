const AppSettings = require('../AppSettings');
const GoogleAnalytics = require('react-native-google-analytics-bridge');

GoogleAnalytics.setTrackerId(AppSettings.GOOGLE_ANALYTICS_ID);

module.exports = {

	/**
	 * Send a log message to the console
	 * @param {string} msg - The message to log
	 */
	log(msg) {
		console.log(msg);
	},

	/**
	 * Send an error message to the console
	 * If debugging is enabled, the message is sent as an error (e.g. stderr)
	 * @param {string} msg - The error message to log
	 */
	error(msg) {
		if (AppSettings.DEBUG_ENABLED) {
			console.error(msg);
		} else {
			console.log(msg);
		}
	},

	/**
	 * Sends a log message to Google Analytics as well as the local console
	 * @param {string} msg - The message to to log
	 */
	ga(msg) {
		this.log(msg);
		GoogleAnalytics.trackScreenView(msg);
	},

};
