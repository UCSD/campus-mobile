import { GoogleAnalyticsTracker } from 'react-native-google-analytics-bridge'
import { Client } from 'bugsnag-react-native'
import { GOOGLE_ANALYTICS_ID } from '../AppSettings'

const tracker = new GoogleAnalyticsTracker(GOOGLE_ANALYTICS_ID),
	bugsnag = new Client()

/**
 * A module containing logging helper functions
 * @module util/logger
 */
module.exports = {

	/** Log message to the console **/
	log(msg) {
		console.log(msg)
	},

	/** Send a trackScreenView message to Google Analytics **/
	ga(msg) {
		tracker.trackScreenView(msg)
	},

	/** Sends a trackEvent message to Google Analytics **/
	trackEvent(category, action) {
		tracker.trackEvent(category, action)
	},

	/** Sends a trackException message to Bugsnag **/
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
