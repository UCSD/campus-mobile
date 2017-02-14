const AppSettings = require('../AppSettings');
const GoogleAnalytics = require('react-native-google-analytics-bridge');

GoogleAnalytics.setTrackerId(AppSettings.GOOGLE_ANALYTICS_ID);

/**
 * A module containing logging helper functions
 * @module util/logger
 */
module.exports = {

	/**
	 * Send a log message to the console
	 * @function log
	 * @param {string} msg The message to log
	 */
	log(msg) {
		console.log(msg);
	},

	/**
	 * Send an error message to the console
	 * If debugging is enabled, the message is sent as an error (e.g. stderr)
	 * @function error
	 * @param {string} msg The error message to log
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
	 * @function ga
	 * @param {string} msg The message to to log
	 */
	ga(msg) {
		this.log(msg);
		GoogleAnalytics.trackScreenView(msg);
	},

};
