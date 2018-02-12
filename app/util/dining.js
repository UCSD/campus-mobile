import moment from 'moment';

/**
 * A module containing dining-related helper functions
 * @module util/dining
 */
module.exports = {

	/**
	 * Gets the current open or closed status of a restaurant.
	 * @function
	 * @param {object} regularHours Normal operating hours
	 * @param {array} specialHours Special operating hours with dates as keys
	 * @returns {boolean} Returns true if the restaurant is open, false if closed
	 */
	getOpenStatus(regularHours, specialHours) {
		let isOpen = false;
		const now = moment();
		const todayDay = now.format('ddd').toLowerCase();
		let openHours = regularHours[todayDay];

		if (specialHours) {
			const todayDate = now.format('MM/DD/YYYY');
			if (specialHours[todayDate]) {
				openHours = specialHours[todayDate].hours;
			}
		}

		if (openHours) {
			const openHoursArray = openHours.split(',');
			openHoursArray.forEach((hours) => {
				const openTime = moment(hours.substring(0, 4), 'HHmm'),
					closeTime = moment(hours.substring(5, 9), 'HHmm');
				if (openTime > closeTime) closeTime.add(24, 'h');
				if (now.isBetween(openTime, closeTime)) isOpen = true;
			});
		}

		return isOpen;
	},

	/**
	 * Returns array of operating hours.
	 * @function
	 * @param {object} hoursString String representing operating hours (e.g '0900-1600')
	 * @returns {array} Array of objects containing formatted operating hours (hours)
	 */
	parseHours(hoursString) {
		const hoursArray = [];
		// If null, the restaurant is closed that day.
		if (!hoursString) {
			hoursArray.push('Closed');
			return hoursArray;
		}

		hoursString.split(',').forEach((hours) => {
			// If 24 hours, output special string
			if (hours.substring(0, 4) === '0000' && hours.substring(5, 9) === '2359') {
				hoursArray.push('Open 24 Hours');
			} else {
				const openTime = moment(hours.substring(0, 4), 'HHmm'),
					closeTime = moment(hours.substring(5, 9), 'HHmm');
				hoursArray.push(`${openTime.format('h:mm a')} - ${closeTime.format('h:mm a')}`);
			}
		});

		return hoursArray;
	},

	/**
	 * Returns array of operating hours with date titles.
	 * @function
	 * @param {object} weeklyHours Can be regularHours or specialHours returned from API
	 * @returns {array} Array of objects containing days (title) and their hours (hours)
	 */
	parseWeeklyHours(weeklyHours) {
		const readableHours = [];
		Object.keys(weeklyHours).forEach((today) => {
			// Don't take into account special hours that have passed.
			if (moment(today, 'MM/DD/YYYY').isValid() && moment(today, 'MM/DD/YYYY').isSameOrAfter(moment())) {
				// Special Hours
				Object.keys(weeklyHours).forEach((date) => {
					const datesHours = this.parseHours(weeklyHours[date].hours);
					readableHours.push({
						title: `${weeklyHours[date].title} ${moment(date, 'MM/DD/YYYY').format('ddd M/DD')}`,
						hours: datesHours
					});
				});
			} else if (moment(today, 'ddd').isValid()) {
				// Normal day
				const openHours = weeklyHours[today];
				if (openHours) {
					const todaysHours = this.parseHours(openHours);

					readableHours.push({
						title: `${moment(today, 'ddd').format('ddd')}`,
						hours: todaysHours
					});
				} else {
					readableHours.push({
						title: `${moment(today, 'ddd').format('ddd')}`,
						hours: this.parseHours(null)
					});
				}
			}
		});
		return readableHours;
	}
};
