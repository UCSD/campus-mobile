import { GOOGLE_ANALYTICS_ID } from '../AppSettings';
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
	 * @function
	 * @param {string} msg The error message to log
	 */
	error(msg) {
		console.error(msg);
	},

	/**
	 * Sends a log message to Google Analytics
	 * @function
	 * @param {string} msg The message to to log
	 */
	ga(msg) {
		tracker.trackScreenView(msg);
	},

};
