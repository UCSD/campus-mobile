import {
	Animated,
	Easing,
	Platform,
	Linking,
	Dimensions,
} from 'react-native';

const dateFormat = require('dateformat');
const logger = require('./logger');

module.exports = {

	platformIOS() {
		return Platform.OS === 'ios';
	},

	platformAndroid() {
		return Platform.OS === 'android';
	},

	getPlatform() {
		return Platform.OS;
	},

	convertMetersToMiles(meters) {
		return (meters / 1609.344);
	},

	getDistanceMilesStr(miles) {
		return (miles.toFixed(1) + ' mi');
	},

	openURL(url) {
		Linking.canOpenURL(url).then(supported => {
			if (!supported) {
				logger.log('ERR: openURL: Unable to handle url: ' + url);
			} else {
				return Linking.openURL(url);
			}
		}).catch(err => logger.log('ERR: openURL: ' + err));
	},

	getDirectionsURL(method, stopLat, stopLon) {
		let directionsURL;

		if (this.platformIOS()) {
			if (method === 'walk') {
				directionsURL = 'http://maps.apple.com/?saddr=Current%20Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=w';
			} else {
				// Default to driving directions
				directionsURL = 'http://maps.apple.com/?saddr=Current%20Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=d';
			}
		} else {
			if (method === 'walk') {
				// directionsURL = 'https://www.google.com/maps/dir/' + startLat + ',' + startLon + '/' + stopLat + ',' + stopLon + '/@' + startLat + ',' + startLon + ',18z/data=!4m2!4m1!3e1';
				directionsURL = 'https://maps.google.com/maps?saddr=Current+Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=w';
			} else {
				// Default to driving directions
				directionsURL = 'https://maps.google.com/maps?saddr=Current+Location&daddr=' + stopLat + ',' + stopLon + '&dirflg=d';
			}
		}

		return directionsURL;
	},

	gotoNavigationApp(method, destinationLat, destinationLon) {
		const destinationURL = this.getDirectionsURL('walk', destinationLat, destinationLon );
		this.openURL(destinationURL);
	},

	startReloadAnimation2(anim, toVal, duration) {
		Animated.timing(anim, { toValue: toVal, duration, easing: Easing.linear }).start();
	},

	startReloadAnimation(anim) {
		Animated.timing(anim, { toValue: 100, duration: 60000, easing: Easing.linear }).start();
	},

	stopReloadAnimation(anim) {
		Animated.timing(anim, { toValue: 0, duration: 0 }).start();
	},

	round(number) {
		return Math.round(number);
	},

	getPRM() {
		const windowWidth = Dimensions.get('window').width;
		const windowHeight = Dimensions.get('window').height;
		const appDefaultWidth = 414;
		return (windowWidth / appDefaultWidth);
	},

	getMaxCardWidth() {
		const windowSize = Dimensions.get('window');
		const windowWidth = windowSize.width;

		return windowWidth - 2 - 12;
	},

	getCampusPrimary() {
		return '#182B49';
	},

	getCurrentTimestamp() {
		return Math.round(Date.now() / 1000);
	},

	getTimestampNumeric() {
		return (dateFormat(Date.now(), 'yyyymmdd'));
	},

	getTimestamp(format) {
		return (dateFormat(Date.now(), format));
	},

	getDateNow() {
		return (Date.now());
	},

	militaryToAMPM(time) {
		let militaryTime = time.substring(0, 5).replace(':','');
		let militaryTimeHH,
			militaryTimeMM,
			militaryTimeAMPM;

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

		if (militaryTimeHH === '0') {
			militaryTimeHH = '12';
		}

		if (militaryTimeMM === '00') {
			militaryTimeMM = '';
		}

		if (militaryTimeMM.length > 0) {
			return (militaryTimeHH + ':' + militaryTimeMM + militaryTimeAMPM);
		} else {
			return (militaryTimeHH + militaryTimeAMPM);
		}
	},

	getRandomColorArray(length) {
		const randomColors = [];
		for (let i = 0; i < length; ++i) {
			randomColors.push(this.getRandomColor());
		}
		return randomColors;
	},

	// Generates random color hex
	getRandomColor() {
		return '#' + ('000000' + Math.random().toString(16).slice(2, 8).toUpperCase()).slice(-6);
	},

	dynamicSort(property) {
		return function(a, b) {
			return (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
		}
	},

	sortNearbyMarkers(a, b) {
		if (a.distance < b.distance) {
			return -1;
		} else if (a.distance > b.distance) {
			return 1;
		} else {
			return 0;
		}
	}
};
