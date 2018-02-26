import React from 'react';
import {
	View,
	Text,
} from 'react-native';
import moment from 'moment';

import ColoredDot from '../common/ColoredDot';
import {
	COLOR_PRIMARY,
	COLOR_MGREEN,
	COLOR_MRED
} from '../../styles/ColorConstants';
import css from '../../styles/css';

const dining = require('../../util/dining');

const generateHourElements = (hoursArray, status, today) => {
	const elementsArray = [];

	// Push hours
	hoursArray.forEach((hours) => {
		const operatingHours = dining.parseHours(hours);
		const isAlwaysOpen = (hours === '0000-2359');
		const activeDotColor = status.isOpen ?
			COLOR_MGREEN : COLOR_MRED;
		const todaysStatusElement = (
			status.currentHours.openingHour.isSame(today, 'day')
			&& status.currentHours.openingHour.isSame(operatingHours.openingHour)
			&& status.currentHours.closingHour.isSame(operatingHours.closingHour)
		) ?
			(
				<View>
					<ColoredDot
						size={10}
						color={activeDotColor}
						style={css.dl_status_icon}
					/>
				</View>
			) : (
				null
			);

		const newHourElement = (
			<View key={hours} style={css.dd_hours_text_container}>
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

		const todaysHoursArray = todaysHours.split(',');
		const todaysTitle = moment(day, 'ddd').format('dddd');
		const todaysHoursElements = generateHourElements(todaysHoursArray, status, moment(day, 'ddd'));

		const newHourRow = (
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

		hoursRows.push(newHourRow);
	});
	return hoursRows;
};

const generateSpecialHours = (allHours, status) => {
	const hoursRows = [];
	const now = moment();
	const todaysHours = allHours[now.format('MM/DD/YYYY')].hours;
	const todaysHoursArray = todaysHours.split(',');
	const todaysTitle = allHours[now.format('MM/DD/YYYY')].title;
	const todaysHoursElements = generateHourElements(todaysHoursArray, status, now);

	const newHourRow = (
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

	hoursRows.push(newHourRow);

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
		<View style={[style]}>
			{hoursElements}
		</View>
	);
};

export default DiningHours;
