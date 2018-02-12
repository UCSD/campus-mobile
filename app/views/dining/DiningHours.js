import React from 'react';
import {
	View,
	Text,
} from 'react-native';

import css from '../../styles/css';

const dining = require('../../util/dining');

const generateHourText = (parsedHours, textRows) => {
	parsedHours.forEach((day) => {
		let hoursText = [];
		if (day.hours.length > 1) {
			day.hours.forEach((hours, i, total) => {
				if (i !== total.length - 1) {
					hoursText.push(`${hours},\n`);
				} else {
					hoursText.push(hours);
				}
			});
		} else {
			hoursText = day.hours;
		}
		textRows.push(<Text key={day.title}>{day.title}: <Text style={css.dd_hours_text_bold}>{hoursText}</Text></Text>);
	});
};

const DiningHours = ({ hours, specialHours, style }) => {
	const hoursParsed = dining.parseWeeklyHours(hours),
		hoursTextRows = [];

	if (specialHours) {
		hoursTextRows.push(<Text key={0}>Special Hours:</Text>);
	}

	generateHourText(hoursParsed, hoursTextRows);

	return (
		<View style={[css.dd_hours_container, style]}>
			{hoursTextRows}
		</View>
	);
};

export default DiningHours;
