import moment from 'moment';

/**
 * A module containing dining-related helper functions
 * @module util/dining
 */
module.exports = {
	/**
	 * Parses hours from API into a moment object.
	 * @function
	 * @param {string} hours Set of opening and closing hours
	 * @returns {object} Returns object:
	 *  {
	 *   opening: object,
	 *   closing: object
	 *  }
	 */
	parseHours(hours) {
		const openingTimeMoment = moment(hours.substring(0,4), 'HHmm');
		const closingTimeMoment = moment(hours.substring(5,9), 'HHmm');

		return {
			openingHour: openingTimeMoment,
			closingHour: closingTimeMoment
		};
	},

	/**
	 * Gets the current open or closed status of a restaurant.
	 * @function
	 * @param {object} regularHours Normal operating hours
	 * @param {object} specialHours Special operating hours with dates as keys
	 * @returns {object} Returns object:
	 *  {
	 *   isOpen: Boolean,
	 *   openingSoon: Boolean,
	 *   closingSoon: Boolean
	 *  }
	 */
	getOpenStatus(regularHours, specialHours) {
		const openStatus = {
			isOpen: false,
			isAlwaysOpen: false,
			openingSoon: false,
			closingSoon: false
		};

		const now = moment();
		let todaysHours = regularHours[now.format('ddd').toLowerCase()];
		if (specialHours && specialHours[now.format('MM/DD/YYYY')]) {
			todaysHours = specialHours[now.format('MM/DD/YYYY')].hours;
		}

		// if 24 hours, return immediately
		if (todaysHours === '0000-2359') {
			openStatus.isOpen = true;
			openStatus.isAlwaysOpen = true;
			return openStatus;
		}

		// If restaurant operates today
		if (todaysHours) {
			const todaysHoursArray = todaysHours.split(',');

			// Keeps record of hours that apply to right now
			let currentHoursIndex = 0;
			let currentHoursDistance;

			todaysHoursArray.forEach((hours, i) => {
				const operatingHours = this.parseHours(hours);

				// Take into account closing times that are the next day
				if (operatingHours.closingHour.isBefore(operatingHours.openingHour)) {
					operatingHours.closingHour.add(1, 'days');
				}

				if (now.isBetween(operatingHours.openingHour, operatingHours.closingHour)) {
					// Restaurant is open during these hours.
					openStatus.isOpen = true;
					currentHoursIndex = i;
				}
				else {
					// Restaurant is closed during these hours.
					if (!openStatus.isOpen) {
						const todaysDistance = Math.abs(operatingHours.openingHour - now);
						// Set current hour index if this closing time is
						// closer to present time than the previous one.
						// Initialize currentHourDistance if not intialized.
						if (!currentHoursDistance) {
							currentHoursIndex = i;
							currentHoursDistance = todaysDistance;
						}
						else if (todaysDistance < currentHoursDistance) {
							currentHoursIndex = i;
							currentHoursDistance = todaysDistance;
						}
					}
				}
			});

			// Check if restaurant is opening or closing soon
			const currentOperatingHours = this.parseHours(todaysHoursArray[currentHoursIndex]);
			const closingHourMinusOne = currentOperatingHours.closingHour.clone().subtract(1, 'hours');
			const openingHourMinusOne = currentOperatingHours.openingHour.clone().subtract(1, 'hours');

			if (now.isBetween(closingHourMinusOne, currentOperatingHours.closingHour)) {
				openStatus.closingSoon = true;
			}
			else if (now.isBetween(openingHourMinusOne, currentOperatingHours.openingHour)) {
				openStatus.openingSoon = true;
			}
		}

		return openStatus;
	},
};
