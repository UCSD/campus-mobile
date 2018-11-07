import { GoogleAnalyticsTracker } from 'react-native-google-analytics-bridge'
import { Client } from 'bugsnag-react-native' 

import { GOOGLE_ANALYTICS_ID } from '../AppSettings'

const tracker = new GoogleAnalyticsTracker(GOOGLE_ANALYTICS_ID)
const bugsnag = new Client()

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
		console.log(msg)
	},

	/**
	 * Sends a trackScreenView message to Google Analytics
	 * @function
	 * @param {string} msg The message to log
	 */
	ga(msg) {
		tracker.trackScreenView(msg)
	},


	/**
	 * Sends a trackEvent message to Google Analytics
	 * @function
	 * @param {string} category The category of event
	 * @param {string} action The name of the action
	 */
	trackEvent(category, action) {
		tracker.trackEvent(category, action)
	},

	/**
	 * Sends a trackException message to Bugsnag
	 * @function
	 * @param {string} error The error message
	 * @param {bool} fatal If the crash was fatal or not
	 */
	trackException(error, metadata, fatal) {
		let severity = 'warning'
		if (fatal) severity = 'error'

		if (__DEV__) {
			console.log(error, metadata, fatal)
		}

		bugsnag.notify(error, (report) => {
			report.severity = severity
			if (metadata) {
				report.metadata = {
					...report.metadata,
					loggerData: { ...metadata }
				}
			}
		})
	},

}
