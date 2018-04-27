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
	 * Sends a trackScreenView message to Google Analytics
	 * @function
	 * @param {string} msg The message to log
	 */
	ga(msg) {
		tracker.trackScreenView(msg);
	},


	/**
	 * Sends a trackEvent message to Google Analytics
	 * @function
	 * @param {string} category The category of event
	 * @param {string} action The name of the action
	 */
	trackEvent(category, action) {
		tracker.trackEvent(category, action);
	},

	/**
	 * Sends a trackException message to Google Analytics
	 * @function
	 * @param {string} error The error message
	 * @param {bool} fatal If the crash was fatal or not
	 */
	trackException(error, fatal) {
		tracker.trackException(error, fatal);
	},

};
