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
	 * @param {array} specialHours Special operating hours with dates as keys
	 * @returns {object} Returns object:
	 *  {
	 *   isOpen: Boolean,
	 *   isOpeningSoon: Boolean,
	 *   isClosingSoon: Boolean,
	 *   todayTitle: String, // if special event
	 *   todaysHours: String
	 *  }
	 */
	getOpenStatus(regularHours, specialHours) {
		const openStatus = {
			isOpen: false,
			isOpeningSoon: false,
			isClosingSoon: false,
			todaysTitle: null,
			todaysHours: null
		};

		const now = moment();
		let todaysHours = regularHours[now.format('ddd').toLowerCase()];

		if (specialHours && specialHours[now.format('MM/DD/YYYY')]) {
			todaysHours = specialHours[now.format('MM/DD/YYYY')].hours;
			openStatus.todaysTitle = specialHours[now.format('MM/DD/YYYY')].title;
		}

		// if 24 hours, return immediately
		if (todaysHours === '0000-2359') {
			openStatus.isOpen = true;
			openStatus.todaysHours = '0000-2359';
			return openStatus;
		}

		const closestTimes = {
			closing: null,
			opening: null
		};

		// If restaurant operates today
		if (todaysHours) {
			todaysHours.split(',').forEach((hours) => {
				const operatingHours = this.parseHours(hours);

				if (now.isBetween(operatingHours.openingHour, operatingHours.closingHour)) {
					openStatus.isOpen = true;
					closestTimes.opening = null;
					closestTimes.closing = operatingHours.closingHour;
					openStatus.todaysHours = hours;
				} else {
					// Restaurant is currently closed. Opening soon?
					if (!closestTimes.opening) {
						closestTimes.opening = operatingHours.openingHour;
						openStatus.todaysHours = hours;
					} else {
						// is the current opening time closer?
						if (operatingHours.openingHour - now < Math.abs(closestTimes.opening - now)) {
							closestTimes.opening = operatingHours.openingHour;
							openStatus.todaysHours = hours;
						}
					}
				}
			});
		}
		if (closestTimes.opening) {
			const { opening } = closestTimes;
			const openingMinusOne = opening.clone().subtract(1, 'h');
			openStatus.isOpeningSoon = now.isBetween(openingMinusOne, opening);
		}
		else if (closestTimes.closing) {
			const { closing } = closestTimes;
			const closingMinusOne = closing.clone().subtract(1, 'h');
			openStatus.isClosingSoon = now.isBetween(closingMinusOne, closing);
		}

		return openStatus;
	},
};
