'use strict';
var React = require('react-native');
var {
	Animated,
	Easing,
} = React;

var dateFormat = require('dateformat');

module.exports = {
	
	startReloadAnimation2: function(anim, toVal, duration) {
		Animated.timing(anim, { toValue: toVal, duration: duration, easing: Easing.linear }).start();
	},

	startReloadAnimation: function(anim) {
		Animated.timing(anim, { toValue: 100, duration: 60000, easing: Easing.linear }).start();
	},

	stopReloadAnimation: function(anim) {
		Animated.timing(anim, { toValue: 0, duration: 0 }).start();
	},

	getCurrentTimestamp: function() {
		return (Math.floor(Date.now() / 1000));
	},

	getTimestampNumeric: function() {
		return(dateFormat(Date.now(), 'yyyymmdd'));
	}

};