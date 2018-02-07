import React from 'react';
import {
	View,
	Text,
	StyleSheet
} from 'react-native';
import DiningHours from './DiningHours';

const DiningDescription = ({ name, description, regularHours, specialHours }) => (
	<View style={styles.descriptionContainer}>
		<Text style={styles.nameText}>{name}</Text>
		{description ? (
			<Text style={styles.subText}>{description}</Text>
		) : null }
		
		<DiningHours
			regularHours={regularHours}
			specialHours={specialHours}
			customStyle={styles.diningHours}
		/>
		{specialHours ? (
			<Text style={styles.subText}>Special Hours:{'\n'}{specialHours}</Text>
		) : null }
	</View>
);

const styles = StyleSheet.create({
	descriptionContainer: { padding: 10 },
	nameText: { fontSize: 26 },
	subText: { paddingTop: 6 },
	diningHours: { paddingTop: 10 },
});

export default DiningDescription;
