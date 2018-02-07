import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';
import {
	COLOR_DGREY,
} from '../../styles/ColorConstants';
import moment from 'moment';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

const DiningOpen = ({ regularHours, specialHours }) => {
	const now = moment(),
		  nowMilitary = now.format('Hmm').toLowerCase(),
		  dayOfWeek = now.format('ddd').toLowerCase(),
		  openHours = regularHours[dayOfWeek];

	let open = false,
		openTime,
		closeTime,
		openText;

	if (openHours) {
		openTime = parseInt(openHours.substring(0,4));
		closeTime = parseInt(openHours.substring(5,9));
		if (nowMilitary >= openTime && nowMilitary <= closeTime) {
			open = true;
			openText = 'Open now';
		} else {
			openText = 'Closed';
		}
	} else {
		openText = 'Closed';
	}

	return (
		<View style={styles.openContainer}>
			<Icon name={'clock'} size={16} style={open ? styles.openIcon : styles.closedIcon} />
			<Text style={open ? styles.openText : styles.closedText}>{openText}</Text>
		</View>
	);
}

const styles = StyleSheet.create({
	openContainer: { flexDirection: 'row', alignItems: 'center'},
	openIcon: { color: '#41A700', paddingRight: 6 },
	closedIcon: { color: '#D32322', paddingRight: 6 },
	openText: { color: '#41A700', fontWeight: '700', fontSize: 12 },
	closedText: { color: '#D32322', fontWeight: '700', fontSize: 12 },
});

export default DiningOpen;
