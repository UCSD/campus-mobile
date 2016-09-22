'use strict';
var AppSettings = require('../AppSettings');
var GoogleAnalytics = require('react-native-google-analytics-bridge');
GoogleAnalytics.setTrackerId(AppSettings.GOOGLE_ANALYTICS_ID);

module.exports = {

	log: function(msg) {
		if (AppSettings.DEBUG_ENABLED) {
			console.log(msg);
		}
	},

	error: function(msg) {
		if (AppSettings.DEBUG_ENABLED) {
			console.error(msg);
		}
	},

	ga: function(msg) {
		this.log(msg);
		GoogleAnalytics.trackScreenView(msg);
	},

};