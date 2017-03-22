import { GOOGLE_ANALYTICS_ID, DEBUG_ENABLED } from '../AppSettings';
import { GoogleAnalyticsTracker } from 'react-native-google-analytics-bridge';

let tracker = new GoogleAnalyticsTracker(GOOGLE_ANALYTICS_ID);

/**
 * A module containing logging helper functions
 * @module util/logger
 */
module.exports = {

	/**
	 * Send a log message to the console
	 * @function
	 * @param {string} msg The message to log
	 */
	log(msg) {
		console.log(msg);
	},

	/**
	 * Send an error message to the console
	 * If debugging is enabled, the message is sent as an error (e.g. stderr)
	 * @function
	 * @param {string} msg The error message to log
	 */
	error(msg) {
		if (DEBUG_ENABLED) {
			console.error(msg);
		} else {
			console.log(msg);
		}
	},

	/**
	 * Sends a log message to Google Analytics as well as the local console
	 * @function
	 * @param {string} msg The message to to log
	 */
	ga(msg) {
		this.log(msg);
		tracker.trackScreenView(msg);
	},

};
