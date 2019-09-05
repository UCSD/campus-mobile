import firebase from 'react-native-firebase'
import { Client } from 'bugsnag-react-native'

const bugsnag = new Client()

const Analytics = firebase.analytics()

/**
 * A module containing logging helper functions
 * @module util/logger
 */
module.exports = {

	/** Log message to the console **/
	log(msg) {
		console.log(msg)
	},

	/** Send a trackScreenView message to Analytics service **/
	trackScreen(msg) {
		Analytics.setCurrentScreen(msg)
	},

	/** Sends a trackEvent message to Analytics service **/
	trackEvent(category, action) {
		Analytics.logEvent(category, action)
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
