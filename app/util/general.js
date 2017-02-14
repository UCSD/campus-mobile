import {
	Animated,
	Easing,
	Platform,
	Linking,
	Dimensions,
} from 'react-native';

const dateFormat = require('dateformat');
const logger = require('./logger');

/**
 * A module containing general helper functions
 * @module util/general
 */
module.exports = {

	/**
	 * Gets whether or not the current platform the app is running on is IOS
	 * @function platformIOS
	 * @returns {boolean} True if the platform is IOS, false otherwise
	 */
	platformIOS() {
		return Platform.OS === 'ios';
	},

	/**
	 * Gets whether or not the current platform the app is running on is Android
	 * @function platformAndroid
	 * @returns {boolean} True if the platform is Android, false otherwise
	 */
	platformAndroid() {
		return Platform.OS === 'android';
	},

	/**
	 * Gets the current platform ths app is running on
	 * @function getPlatform
	 * @returns {string} The platform name
	 */
	getPlatform() {
		return Platform.OS;
	},

	/**
	 * Converts a numerical quantity from meters to miles
	 * @function convertMetersToMiles
	 * @param {number} meters The quantity to convert
	 * @returns {number} The quantity now converted into miles
	 */
	convertMetersToMiles(meters) {
		return (meters / 1609.344);
	},

	/**
	 * Gets a string representation of a given quantity of miles (up to and including a single decimal place)
	 * @function getDistanceMilesStr
	 * @param {number} miles The quantity to convert to a string
	 * @returns {number} The miles quantity now as a string
	 */
	getDistanceMilesStr(miles) {
		return (miles.toFixed(1) + ' mi');
	},

	/**
	 * Attempts to open the provided URL for displaying to the user
	 * @function openURL
	 * @param {string} url The URL to open
	 * @returns {boolean|undefined} If the URL cannot be opened, this logs to console. Otherwise, returns true.
	 * False can only be returned if the ability to open a URL changes between the check and the opening itself.
	 * @todo Develop a more explicit/consistent return for this method
	 */
	openURL(url) {
		Linking.canOpenURL(url).then(supported => {
			if (!supported) {
				logger.log('ERR: openURL: Unable to handle url: ' + url);
			} else {
				return Linking.openURL(url);
			}
		}).catch(err => logger.log('ERR: openURL: ' + err));
	},

	/**
	 * Gets the URL for obtaining directions to a given location via a given transportation method
	 * @function getDirectionsURL
	 * @param {string} method Can be "walk" or anything else. Anything else will result in a URL for driving.
	 * @param {string|number} stopLat The latitude of the destination
	 * @param {string|number} stopLon The longitude of the destination
	 * @return {string} A platform-specific URL for obtaining the directions
	 */
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

	doPRM(num) {
		const windowWidth = Dimensions.get('window').width;
		const appDefaultWidth = 414;
		const prm = (windowWidth / appDefaultWidth);

		return Math.round(num * prm);
	},

	getMaxCardWidth() {
		const windowSize = Dimensions.get('window');
		const windowWidth = windowSize.width;

		return windowWidth - 2 - 12;
	},

	/**
	 * Gets the UCSD campus primary color in hexidecimal form
	 * @function getCampusPrimary
	 * @returns {string} The string "#182B49" which represents a dark blue color
	 */
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

	/**
	 * Generates random color hex
	 * @function getRandomColor
	 * @returns {string} A randomly generated hex color code
	 */
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
