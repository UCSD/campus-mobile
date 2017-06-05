import React from 'react';
import {
	Text,
	StyleSheet,
} from 'react-native';
import moment from 'moment';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const DiningHours = ({ regularHours, specialHours, customStyle }) => {
	
	if (specialHours) {
		return null;
	} else {
		const now = moment(),
			  nowMilitary = now.format('Hmm').toLowerCase(),
			  dayOfWeek = now.format('ddd').toLowerCase(),
			  openHours = regularHours[dayOfWeek];

		let open = false,
			openStr = '',
			closeStr = '';

		if (openHours) {
			const openTime = parseInt(openHours.substring(0,4)),
				  openTimeStr = openHours.substring(0,4),
				  closeTime = parseInt(openHours.substring(5,9)),
				  closeTimeStr = openHours.substring(5,9),
				  openAMPM = (openTime < 1200) ? 'am' : 'pm',
				  closeAMPM = (closeTime < 1200) ? 'am' : 'pm';
			
			openStr = formatTime(openTimeStr, openAMPM);
			closeStr = formatTime(closeTimeStr, closeAMPM);

			if (closeTime <= openTime) {
				// Restaurant closes the next morning/day
				if (nowMilitary <= closeTime) {
					open = true;
				} else if (nowMilitary >= openTime) {
					open = true;
				}
			} else if (nowMilitary >= openTime && nowMilitary <= closeTime) {
				// Restaurant closes later the same day
				open = true;
			}
		}

		if (open) {
			return (
				<Text style={[styles.hoursMain, customStyle]}>Open now: <Text style={styles.hoursOpen}>{openStr} - {closeStr}</Text></Text>
			);
		} else {
			return (
				<Text style={[styles.hoursMain, styles.hoursClosed, customStyle]}>Closed. {openHours ? (
					<Text style={styles.hoursOpen}>Hours {openStr} - {closeStr}</Text>
				) : null}</Text>
			);
		}
	}
}

function formatTime(time, ampm) {
	let timeHH = time.substring(0,2),
		timeMM = time.substring(2,4),
		timeStr = '';

	timeHH = parseInt(timeHH);
	timeMM = parseInt(timeMM);

	if (timeHH > 12) {
		timeHH -= 12;
	} else if (timeHH === 0) {
		timeHH = '12';
	}
	if (timeMM === 0) {
		timeMM = '00';
	}

	return (timeHH + ':' + timeMM + ' ' + ampm);
}

const styles = StyleSheet.create({
	hoursMain: { paddingTop: 2 },
	hoursOpen: { fontWeight: '500' },
	hoursClosed: { fontWeight: '500', color: '#D32322' },
});

export default DiningHours;
