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

		const newTextRow = (
			<View
				key={day.title}
				style={css.dd_hours_row}
			>
				<Text style={css.dd_hours_text_title}>
					{day.title}:
				</Text>
				<Text style={css.dd_hours_text_hours}>
					{hoursText}
				</Text>
			</View>
		);

		textRows.push(newTextRow);
	});
};

const DiningHours = ({ hours, specialHours, style }) => {
	const hoursParsed = dining.parseWeeklyHours(hours),
		hoursTextRows = [];

	if (specialHours) {
		hoursTextRows.push(<Text key={0} style={css.dd_description_subtext}>Special Hours</Text>);
	}

	generateHourText(hoursParsed, hoursTextRows);

	return (
		<View style={[css.dd_hours_container, style]}>
			{hoursTextRows}
		</View>
	);
};

export default DiningHours;
