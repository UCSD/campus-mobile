import {
	Platform,
	Linking,
	Dimensions,
	Keyboard,
	Alert,
	AsyncStorage
} from 'react-native'
import RNRestart from 'react-native-restart'
import RNExitApp from 'react-native-exit-app'
import dateFormat from 'dateformat'

import { COLOR_PRIMARY, COLOR_SECONDARY } from '../styles/ColorConstants'
import logger from './logger'

/**
 * A module containing general helper functions
 * @module general
 */
module.exports = {

	/**
	 * Gets whether or not the current platform the app is running on is IOS
	 * @returns {boolean} True if the platform is IOS, false otherwise
	 */
	platformIOS() {
		return Platform.OS === 'ios'
	},

	/**
	 * Gets whether or not the current platform the app is running on is Android
	 * @memberOf util/general
	 * @returns {boolean} True if the platform is Android, false otherwise
	 */
	platformAndroid() {
		return Platform.OS === 'android'
	},

	/**
	 * Gets the current platform ths app is running on
	 * @returns {string} The platform name
	 */
	getPlatform() {
		return Platform.OS
	},

	/**
	 * Checks to see if the device model is iPhone X based on the viewport height
	 * @returns {boolean} True if the device model is iPhone X, false otherwise
	 */
	deviceIphoneX() {
		return Dimensions.get('window').height === 812
	},

	/**
	 * Converts a numerical quantity from meters to miles
	 * @memberOf util/general
	 * @param {number} meters The quantity to convert
	 * @returns {number} The quantity now converted into miles
	 */
	convertMetersToMiles(meters) {
		return (meters / 1609.344)
	},

	/**
	 * Gets a string representation of a given quantity of miles (up to and including a single decimal place)
	 * @param {number} miles The quantity to convert to a string
	 * @returns {number} The miles quantity now as a string
	 */
	getDistanceMilesStr(miles) {
		return (miles.toFixed(1) + ' mi')
	},

	/**
	 * Attempts to open the provided URL for displaying to the user
	 * @param {string} url The URL to open
	 * @returns {boolean} If the URL cannot be opened, this logs to console and returns false. Otherwise, returns true.
	 */
	openURL(url) {
		Linking.canOpenURL(url).then((supported) => {
			if (!supported) {
				logger.log('ERR: openURL: Unable to handle url: ' + url)
				return false
			} else {
				return Linking.openURL(url)
			}
		}).catch((err) => {
			logger.log('ERR: openURL: ' + err)
			return false
		})
	},

	/**
	 * Gets the URL for obtaining directions to a given location via a given transportation method
	 * @param {string} method Can be "walk" or anything else. Anything else will result in a URL for driving.
	 * @param {string|number} stopLat The latitude of the destination
	 * @param {string|number} stopLon The longitude of the destination
	 * @param {string} address The destination's address
	 * @return {string} A platform-specific URL for obtaining the directions
	 */
	getDirectionsURL(method, stopLat, stopLon, address) {
		let directionsURL
		let directionsAddr

		if (stopLat && stopLon) directionsAddr = `${stopLat},${stopLon}`
		if (address) directionsAddr = address

		if (this.platformIOS()) {
			if (method === 'walk') {
				directionsURL = `http://maps.apple.com/?daddr=${directionsAddr}&dirflg=w`
			} else {
				// Default to driving directions
				directionsURL = `http://maps.apple.com/?daddr=${directionsAddr}&dirflg=d`
			}
		} else {
			if (method === 'walk') {
				// directionsURL = 'https://www.google.com/maps/dir/' + startLat + ',' + startLon + '/' + stopLat + ',' + stopLon + '/@' + startLat + ',' + startLon + ',18z/data=!4m2!4m1!3e1'
				directionsURL = 'https://maps.google.com/maps?saddr=Current+Location&daddr=' + directionsAddr + '&dirflg=w'
			} else {
				// Default to driving directions
				directionsURL = 'https://maps.google.com/maps?saddr=Current+Location&daddr=' + directionsAddr + '&dirflg=d'
			}
		}

		return directionsURL
	},

	/**
	 * Attempts to redirect the device to its navigation app
	 * @param {string|number} destinationLat The destination's latitude
	 * @param {string|number} destinationLon The destination's longitude
	 * @param {string} destinationAddress The destination's address
	 * @returns {boolean} true/false depending if navigation app is opened
	 */
	gotoNavigationApp(destinationLat, destinationLon, destinationAddress) {
		if (destinationLat && destinationLon) {
			const destinationURL = module.exports.getDirectionsURL('walk', destinationLat, destinationLon )
			return module.exports.openURL(destinationURL)
		}
		else if (destinationAddress) {
			const destinationURL = module.exports.getDirectionsURL('walk', null, null, destinationAddress )
			return module.exports.openURL(destinationURL)
		}
	},

	/**
	 * Rounds a number to the nearest integer
	 * As examples: 2.49 will be rounded down to 2, while 2.5 will be rounded up to 3
	 * @param {number} number The number to round
	 * @returns {number} The rounded number
	 */
	round(number) {
		return Math.round(number)
	},

	/**
	 * Gets the pixel-ratio-modifier needed for this device window
	 * The modifier is a ratio to be used for scaling GUI elements based on the default sizes
	 * @returns {number} The ratio of current window width vs the app's default width
	 * @todo The variable windowHeight is unused
	 */
	getPRM() {
		const windowWidth = Dimensions.get('window').width
		const appDefaultWidth = 414
		return (windowWidth / appDefaultWidth)
	},

	/**
	 * Modifies the input value by the pixel-ration-modifier
	 * This can be used to scale a GUI element's size for the current device
	 * @param {number} num The number/size to scale
	 * @returns {number} The now-scaled number/size
	 * @todo This method could call this.getPRM() to prevent redundant code
	 */
	doPRM(num) {
		const windowWidth = Dimensions.get('window').width
		const appDefaultWidth = 414
		const prm = (windowWidth / appDefaultWidth)

		return Math.round(num * prm)
	},

	/**
	 * Gets the maximum width for a card occupying a screen/window
	 * @returns {number} The maximum width in points
	 */
	getMaxCardWidth() {
		return Dimensions.get('window').width - 2 - 12
	},

	/**
	 * Gets the screen width of the users device
	 * @returns {number} The screen width in points
	 */
	getScreenWidth() {
		return Dimensions.get('window').width
	},

	/**
	 * Gets the screen height of the users device
	 * @returns {number} The screen height in points
	 */
	getScreenHeight() {
		return Dimensions.get('window').height
	},

	/**
	 * Gets the UCSD campus primary color in hexidecimal form
	 * @returns {string}
	 */
	getCampusPrimary() {
		return COLOR_PRIMARY
	},

	/**
	 * Gets the UCSD campus secondary color in hexidecimal form
	 * @returns {string}
	 */
	getCampusSecondary() {
		return COLOR_SECONDARY
	},

	/**
	 * Gets the current timestamp in seconds
	 * @returns {number} The number of seconds since midnight Jan 1, 1970
	 */
	getCurrentTimestamp() {
		return Math.round(Date.now() / 1000)
	},

	/**
	 * Gets the current timestamp formatted as a string
	 * @returns {string} The current time formatted to "yyyymmdd"
	 */
	getTimestampNumeric() {
		return (dateFormat(Date.now(), 'yyyymmdd'))
	},

	/**
	 * Gets the current timestamp in a specified format
	 * @param {string} format The format to use (e.g. "yyyymmdd")
	 * @returns {string} The formatted current time
	 */
	getTimestamp(format) {
		return (dateFormat(Date.now(), format))
	},

	/**
	 * Gets the current date
	 * @returns {number} The number of milliseconds since midnight Jan 1, 1970
	 */
	getDateNow() {
		return (Date.now())
	},

	/**
	 * Gets the humanized duration in hours and minutes from two unix timestamps
	 * @param {string|number} startTime Unix time of the start period
	 * @param {string|number} endTime Unix time of the end period
	 * @returns {string} A humanized string indicating an hours & minutes duration in time (i.e. '3 hours 15 mins')
	 */
	getHumanizedDuration(startTime, endTime) {
		let durationStr = '',
			durationHours = 0,
			durationMinutes = (Number(endTime) - Number(startTime)) / (60 * 1000)
		while (durationMinutes >= 60) {
			durationMinutes -= 60
			durationHours += 1
		}
		if (durationHours) {
			durationStr += durationHours + ' hour' + (durationHours > 1 ? 's ' : ' ')
		}
		if (durationMinutes) {
			durationStr += durationMinutes + ' min' + (durationMinutes > 1 ? 's' : '')
		}
		return (durationStr.trim())
	},

	/**
	 * Converts a time string provided in military form to AM-PM form
	 * @param {string} time The time in military form
	 * @returns {string} The time in AM-PM form
	 */
	militaryToAMPM(time) {
		if (time) {
			let militaryTime = time.substring(0, 5).replace(':','')
			let militaryTimeHH,
				militaryTimeMM,
				militaryTimeAMPM

			militaryTime = militaryTime.replace(/^0/,'')

			if (militaryTime.length === 3) {
				militaryTimeHH = militaryTime.substring(0,1)
				militaryTimeMM = militaryTime.substring(1,3)
			} else if (militaryTime.length === 4) {
				militaryTimeHH = militaryTime.substring(0,2)
				militaryTimeMM = militaryTime.substring(2,4)
			}

			if (militaryTimeHH < 12) {
				militaryTimeAMPM = 'am'
			} else {
				militaryTimeAMPM = 'pm'
			}

			if (militaryTimeHH > 12) {
				militaryTimeHH -= 12
			}

			if (militaryTimeHH === '0') {
				militaryTimeHH = '12'
			}

			if (militaryTimeMM === '00') {
				militaryTimeMM = ''
			}

			if (militaryTimeMM.length > 0) {
				return (militaryTimeHH + ':' + militaryTimeMM + militaryTimeAMPM)
			} else {
				return (militaryTimeHH + militaryTimeAMPM)
			}
		} else {
			return ''
		}
	},

	/**
	 * Gets an array containing random colors
	 * @param {number} length The length of the array to return
	 * @returns {number[]} An array with each element containing a randomly generated hex color code
	 */
	getRandomColorArray(length) {
		const randomColors = []
		for (let i = 0; i < length; ++i) {
			randomColors.push(this.getRandomColor())
		}
		return randomColors
	},

	/**
	 * Generates random color hex
	 * @returns {string} A randomly generated hex color code
	 */
	getRandomColor() {
		return '#' + ('000000' + Math.random().toString(16).slice(2, 8).toUpperCase()).slice(-6)
	},

	/**
	 * Gets a linear sorting function based on a given property of the input objects
	 * @param {string} property The property the sorting function should concern itself with
	 * @returns {function} A sorting function that compares inputs based on one of their properties
	 */
	dynamicSort(property) {
		return function (a, b) {
			return (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0
		}
	},

	/**
	 * This is a comparison function used for sorting markers
	 * @param {Object} a The first marker to compare
	 * @param {number} a.distance The first distance
	 * @param {Object} b The second marker to compare
	 * @param {number} b.distance The second distance
	 * @return {number} -1 if a is less-than b, 0 if they are equal, 1 if a is greater-then b
	 * @todo This function is already handled by the one returned by dynamicSort()
	 */
	sortNearbyMarkers(a, b) {
		if (a.distance < b.distance) {
			return -1
		} else if (a.distance > b.distance) {
			return 1
		} else {
			return 0
		}
	},

	/**
	 * @returns {function} Hides the keyboard
	 */
	hideKeyboard() {
		Keyboard.dismiss()
	},

	/**
	 * @param {Object} e Error object with details about the fatal error.
	 * @returns {function} Resets the app in case of a fatal error.
	 */
	gracefulFatalReset(e) {
		logger.trackException(e.toString(), true)
		AsyncStorage.clear()
		Alert.alert(
			'Oops! Something went wrong!',
			'An error report has been automatically sent to the technical staff. Try restarting. If the problem still occurs try again later.',
			[{
				text: 'Reload',
				onPress: () => {
					RNRestart.Restart()
				}
			},
			{
				text: 'Quit',
				style: 'cancel',
				onPress: () => {
					RNExitApp.exitApp()
				}
			}
			],
			{ cancelable: false }
		)
	}
}
