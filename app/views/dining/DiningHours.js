import React from 'react';
import {
	View,
	Text,
} from 'react-native';
import moment from 'moment';

import ColoredDot from '../common/ColoredDot';
import {
	COLOR_MGREEN,
	COLOR_MRED
} from '../../styles/ColorConstants';
import css from '../../styles/css';

const dining = require('../../util/dining');

const generateHourElements = (hoursArray, status, today) => {
	const elementsArray = [];
	let activeDotColor;

	if (status) {
		activeDotColor = status.isOpen ?
			COLOR_MGREEN : COLOR_MRED;
	}

	// Push hours
	hoursArray.forEach((hours) => {
		const operatingHours = dining.parseHours(hours);
		const isAlwaysOpen = (hours === '0000-2359');
		const isClosed = (hours === '0000-0000');
		let todaysStatusElement = null;

		// Check if valid status
		if (status) {
			if (status.currentHours) {
				// Determines if the hours we are currently iterating through
				// match with the current status, right now
				const hoursAreCurrentHours = (
					(
						status.currentHours.openingHour.format('dddd') === today
						|| (
							moment.isMoment(today) &&
							status.currentHours.openingHour.isSame(today, 'day')
						)
					)
					&& status.currentHours.openingHour.isSame(operatingHours.openingHour)
					&& status.currentHours.closingHour.isSame(operatingHours.closingHour)
				);
				if (hoursAreCurrentHours) {
					todaysStatusElement = (
						<View>
							<ColoredDot
								size={10}
								color={activeDotColor}
								style={css.dd_status_icon}
							/>
						</View>
					);
				}
			} else {
				// (currentHours will be null on days restaurants are closed)
				// handle cases where restaurant is closed on a special day
				if (isClosed) {
					todaysStatusElement = (
						<View>
							<ColoredDot
								size={10}
								color={activeDotColor}
								style={css.dd_status_icon}
							/>
						</View>
					);
				}
			}
		} else {
			// Status is invalid, return null
			todaysStatusElement = null;
		}

		let newHourElementHoursText;
		if (isClosed) {
			newHourElementHoursText = 'Closed';
		}
		else if (isAlwaysOpen) {
			newHourElementHoursText = 'Open 24 Hours';
		}
		else if (
			operatingHours.openingHour.format('h:mm a') !== 'Invalid date'
			&& operatingHours.closingHour.format('h:mm a') !== 'Invalid date'
		) {
			newHourElementHoursText = operatingHours.openingHour.format('h:mm a')
				+ ' — '
				+ operatingHours.closingHour.format('h:mm a');
		} else {
			newHourElementHoursText = 'Unknown hours';
		}

		const newHourElement = (
			<View key={hours} style={css.dd_hours_text_container}>
				<Text style={css.dd_hours_text_hours}>
					{newHourElementHoursText}
				</Text>
				{todaysStatusElement}
			</View>
		);

		elementsArray.push(newHourElement);
	});

	return elementsArray;
};

const generateHours = (allHours, status) => {
	const hoursRows = [];
	Object.keys(allHours).forEach((day) => {
		const todaysHours = allHours[day];

		// If no hours for the day don't do anything
		if (!todaysHours) return;

		// If hours are malformed, return 'Unknown hours'
		if (typeof todaysHours !== 'string') {
			const newHourRow = (
				<View
					key={day}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_hours_text_title}>Unknown day:</Text>
					<View style={css.dd_hours_text_hoursyle}>
						<Text style={css.dd_hours_text_hours}>Unknown hours</Text>
					</View>
				</View>
			);

			hoursRows.push(newHourRow);
		} else {
			const todaysHoursArray = todaysHours.split(',');
			const todaysTitle = moment(day, 'ddd').format('dddd');
			const todaysHoursElements = generateHourElements(todaysHoursArray, status, todaysTitle);

			const newHourRow = (
				<View
					key={todaysTitle}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_hours_text_title}>{`${todaysTitle}:`}</Text>
					<View style={css.dd_hours_text_hoursyle}>
						{todaysHoursElements}
					</View>
				</View>
			);

			hoursRows.push(newHourRow);
		}
	});
	return hoursRows;
};

const generateSpecialHours = (allHours, status) => {
	const hoursRows = [];
	const now = moment();
	Object.keys(allHours).forEach((day) => {
		// Skip special hours that are more than a month away
		if (moment(day, 'MM/DD/YYYY').isAfter(now.add(1, 'months'))) return;

		const todaysHours = allHours[day].hours;
		let todaysHoursArray = [];
		let todaysTitle;
		if (allHours[day].title) {
			todaysTitle = `${day} – ${allHours[day].title}`
		} else {
			todaysTitle = `${day} – Unknown`;
		}

		// If hours are malformed, return 'Unknown hours'
		if (typeof todaysHours !== 'string') {
			const newHourRow = (
				<View
					key={day}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_special_hours_text_title}>{`${todaysTitle}:`}</Text>
					<View style={css.dd_hours_text_hoursyle}>
						<Text style={css.dd_hours_text_hours}>Unknown hours</Text>
					</View>
				</View>
			);

			hoursRows.push(newHourRow);
		} else {
			// If no hours for the day, the restaurant is closed
			if (todaysHours) {
				todaysHoursArray = todaysHours.split(',');
			} else {
				todaysHoursArray.push('0000-0000');
			}

			const todaysHoursElements = generateHourElements(todaysHoursArray, status, now);
			const newHourRow = (
				<View
					key={todaysTitle}
					style={css.dd_hours_row}
				>
					<Text style={css.dd_special_hours_text_title}>{`${todaysTitle}:`}</Text>
					<View style={css.dd_hours_text_hoursyle}>
						{todaysHoursElements}
					</View>
				</View>
			);

			hoursRows.push(newHourRow);
		}
	});
	return hoursRows;
};

const DiningHours = ({
	hours,
	status,
	specialHours,
	style
}) => {
	let hoursElements;
	if (specialHours) hoursElements = generateSpecialHours(hours, status);
	else hoursElements = generateHours(hours, status);
	return (
		<View>
			{
				(specialHours && hoursElements.length > 0) ? (
					<Text style={css.dd_description_subtext}>
						Special hours:
					</Text>
				) : null
			}
			<View style={[style]}>
				{hoursElements}
			</View>
		</View>
	);
};

export default DiningHours;
