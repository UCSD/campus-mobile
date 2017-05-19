import React from 'react';
import {
	View,
	Text,
	StyleSheet
} from 'react-native';

import {
	COLOR_DGREY
} from '../../styles/ColorConstants';

const DiningDescription = ({ name, description, regularHours, specialHours }) => (
	<View style={styles.descriptionContainer}>
		<Text style={styles.nameText}>{name}</Text>
		{description ? (
			<Text style={styles.subText}>{description}</Text>
		) : null }
		{regularHours ? (
			<Text style={styles.subText}>{regularHours}</Text>
		) : null }
		{specialHours ? (
			<Text style={styles.subText}>Special Hours:{'\n'}{specialHours}</Text>
		) : null }
	</View>
);

const styles = StyleSheet.create({
	descriptionContainer: { padding: 10 },
	nameText: { color: COLOR_DGREY, fontSize: 26 },
	subText: { color: COLOR_DGREY, paddingTop: 6, fontSize: 14 },
});

export default DiningDescription;
