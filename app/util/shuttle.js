/**
 * A module containing shuttle-related helper functions
 * @module util/shuttle
 */
module.exports = {

	/**
	 * Gets the minutes of "estimated time of arrival" from an amount of seconds
	 * @function
	 * @param {number} secondToArrival The number of seconds until arrival
	 * @returns {string} A user-friendly respresentation of the number of minutes
	 */
	getMinutesETA(secondsToArrival) {
		if (secondsToArrival < 1) {
			return ('Arrived');
		} else if (secondsToArrival < 60) {
			return ('<1 min');
		} else {
			let secondsToArrivalDec = secondsToArrival;
			let minsToArrival = 1;

			while (secondsToArrivalDec > 60) {
				secondsToArrivalDec -= 60;
				minsToArrival++;
			}

			if (minsToArrival === 1) {
				return ('1 min');
			} else {
				return (minsToArrival + ' mins');
			}
		}
	},

};
