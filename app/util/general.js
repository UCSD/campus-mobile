'use strict';
var React = require('react-native');
var {
	Animated,
	Easing,
	Platform,
	Linking,
} = React;

var dateFormat = require('dateformat');

module.exports = {
	
	platformIOS: function() {
		if (Platform.OS === 'ios') {
			return true;
		} else {
			return false;
		}
	},

	platformAndroid: function() {
		if (Platform.OS === 'android') {
			return true;
		} else {
			return false;
		}
	},

	getPlatform: function() {
		return Platform.OS;
	},

	convertMetersToMiles(meters) {
		return (meters / 1609.344);
	},

	getDistanceMilesStr(miles) {
		return (miles.toFixed(1) + ' mi');
	},

	openURL: function(url) {
		Linking.canOpenURL(url).then(supported => {
			if (!supported) {
				logger.log('ERR: openURL: Unable to handle url: ' + url);
			} else {
				return Linking.openURL(url);
			}
		}).catch(err => logger.log('ERR: openURL: ' + err));
	},

	getDirectionsURL: function(method, stopLat, stopLon) {

		var directionsURL;

		if (this.platformIOS()) {
			if (method === 'walk') {
				directionsURL = 'http://maps.apple.com/?saddr=Current%20Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=w';
			} else {
				// Default to driving directions
				directionsURL = 'http://maps.apple.com/?saddr=Current%20Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=d';
			}
		} else {
			if (method === 'walk') {
				//directionsURL = 'https://www.google.com/maps/dir/' + startLat + ',' + startLon + '/' + stopLat + ',' + stopLon + '/@' + startLat + ',' + startLon + ',18z/data=!4m2!4m1!3e1';
				directionsURL = 'https://maps.google.com/maps?saddr=Current+Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=w';
			} else {
				// Default to driving directions
				directionsURL = 'https://maps.google.com/maps?saddr=Current+Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=d';
			}
		}

		return directionsURL;
	},

	gotoNavigationApp(method, destinationLat, destinationLon) {
		var destinationURL = this.getDirectionsURL('walk', destinationLat, destinationLon );
		this.openURL(destinationURL);
	},

	startReloadAnimation2: function(anim, toVal, duration) {
		Animated.timing(anim, { toValue: toVal, duration: duration, easing: Easing.linear }).start();
	},

	startReloadAnimation: function(anim) {
		Animated.timing(anim, { toValue: 100, duration: 60000, easing: Easing.linear }).start();
	},

	stopReloadAnimation: function(anim) {
		Animated.timing(anim, { toValue: 0, duration: 0 }).start();
	},

	getCurrentTimestamp: function(type) {
		if (type === 'int') {
			return Math.round(Date.now() / 1000);
		} else if (type === 'str') {
			return Math.round(Date.now() / 1000).toString()
		} else {
			return;
		}
	},

	getTimestampNumeric: function() {
		return(dateFormat(Date.now(), 'yyyymmdd'));
	},

	getTimestamp: function(format) {
		return(dateFormat(Date.now(), format));
	},

	getDateNow: function() {
		return (Date.now());
	},

	militaryToAMPM: function(militaryTime) {
		var militaryTime, militaryTimeHH, militaryTimeMM, militaryTimeAMPM;
		militaryTime = militaryTime.replace(/^0/,'');

		if (militaryTime.length === 3) {
			militaryTimeHH = militaryTime.substring(0,1);
			militaryTimeMM = militaryTime.substring(1,3);
		} else if (militaryTime.length === 4) {
			militaryTimeHH = militaryTime.substring(0,2);
			militaryTimeMM = militaryTime.substring(2,4);
		}

		if (militaryTimeHH < 12) {
			militaryTimeAMPM = 'am';
		} else {
			militaryTimeAMPM = 'pm';
		}

		if (militaryTimeHH > 12) {
			militaryTimeHH -= 12;
		}

		if (militaryTimeHH == '0') {
			militaryTimeHH = '12';
		}

		if (militaryTimeMM == '00') {
			militaryTimeMM = '';
		}

		if (militaryTimeMM.length > 0) {
			return (militaryTimeHH + ':' + militaryTimeMM + militaryTimeAMPM);
		} else {
			return (militaryTimeHH + militaryTimeAMPM);
		}
	},

	getRandomColorArray:function(length) {
		var randomColors = [];
		for(var i = 0; i < length; ++i) {
			randomColors.push(this.getRandomColor());
		}
		return randomColors;
	},

	// Generates random color hex
	getRandomColor: function() {
		return '#' + ("000000" + Math.random().toString(16).slice(2, 8).toUpperCase()).slice(-6);
	},
	
	sortNearbyMarkers: function(a, b) {
		if (a.distance < b.distance) {
			return -1;
		} else if (a.distance > b.distance) {
			return 1;
		} else {
			return 0;
		}
	}
};