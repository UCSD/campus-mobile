import React from 'react';
import {
	View,
	Text,
} from 'react-native';

const css = require('../../styles/css');
const dining = require('../../util/dining');

const DiningHoursText = ({ title, hours }) => {
	const operatingHours = dining.parseHours(hours);
	console.log(operatingHours, title);

	const dayText = title ? (
		title  + ': trsting dffjda fjlkd '
	) : (
		operatingHours.openingHour.format('dddd') + ':'
	);
	let dayHours = null;

	if (operatingHours.openingHour.format('HHmm') === '0000' &&
		operatingHours.closingHour.format('HHmm') === '2359') {
		dayHours = 'Open 24 Hours';
	}

	return (
		<View style={css.dd_hours_row}>
			<Text style={css.dd_hours_text_title}>
				{dayText}
			</Text>
			<Text style={css.dd_hours_text_hours}>
				9:00 - 10:00 am
			</Text>
		</View>
	);
};

export default DiningHoursText;
