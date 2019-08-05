/**
 * A module containing shuttle-related helper functions
 * @module util/shuttle
 */
module.exports = {
	/**
	 * Gets the minutes of "estimated time of arrival" from an amount of seconds
	 * @param {number} secondsToArrival The number of seconds until arrival
	 * @returns {string} A user-friendly respresentation of the number of minutes
	 */
	getMinutesETA(secondsToArrival) {
		if (secondsToArrival <= 0) {
			return ('Arrived')
		} else if (secondsToArrival < 60) {
			return ('1 min')
		} else {
			let secondsToArrivalDec = secondsToArrival
			let minsToArrival = 1

			while (secondsToArrivalDec > 60) {
				secondsToArrivalDec -= 60
				minsToArrival++
			}

			return (minsToArrival + ' min')
		}
	},
}
