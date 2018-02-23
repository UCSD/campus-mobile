import React from 'react';
import {
	View,
	Text,
} from 'react-native';
import moment from 'moment';

import css from '../../styles/css';

const dining = require('../../util/dining');

const generateHourElements = (hoursArray) => {
	const elementsArray = [];

	// Push hours
	hoursArray.forEach((hours) => {
		const operatingHours = dining.parseHours(hours);
		const isAlwaysOpen = (hours === '0000-2359');
		elementsArray.push(
			<View key={hours}>
				<Text style={css.dd_hours_text_hours}>
					{
						(isAlwaysOpen) ?
							('Open 24 Hours') :
							(
								operatingHours.openingHour.format('h:mm a')
								+ ' - '
								+ operatingHours.closingHour.format('h:mm a')
							)
					}
				</Text>
			</View>
		);
	});

	return elementsArray;
};

const generateHours = (allHours) => {
	const hoursRows = [];
	for (const day of Object.keys(allHours)) {
		const todaysHours = allHours[day];

		// If no hours for the day don't do anything
		if (!todaysHours) break;

		const todaysHoursArray = todaysHours.split(',');
		const todaysTitle = moment(day, 'ddd').format('dddd');
		const todaysHoursElements = generateHourElements(todaysHoursArray);

		hoursRows.push(
			<View
				key={todaysTitle}
				style={css.dd_hours_row}
			>
				<Text style={css.dd_hours_text_title}>{todaysTitle + ':'}</Text>
				<View style={css.dd_hours_text_hoursyle}>
					{todaysHoursElements}
				</View>
			</View>
		);
	}
	return hoursRows;
};

const generateSpecialHours = (allHours) => {
	const hoursRows = [];
	const now = moment();
	const todaysHours = allHours[now.format('MM/DD/YYYY')].hours;
	const todaysHoursArray = todaysHours.split(',');
	const todaysTitle = allHours[now.format('MM/DD/YYYY')].title;
	const todaysHoursElements = generateHourElements(todaysHoursArray);

	hoursRows.push(
		<View
			key={todaysTitle}
			style={css.dd_hours_row}
		>
			<Text style={css.dd_special_hours_text_title}>{todaysTitle + ':'}</Text>
			<View style={css.dd_hours_text_hoursyle}>
				{todaysHoursElements}
			</View>
		</View>
	);

	return hoursRows;
};

const DiningHours = ({ hours, specialHours, style }) => {
	let hoursElements;
	if (specialHours) hoursElements = generateSpecialHours(hours);
	else hoursElements = generateHours(hours);
	return (
		<View style={[style]}>
			{hoursElements}
		</View>
	);
};

export default DiningHours;
