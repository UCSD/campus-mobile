import React from 'react';
import {
	Text,
	View,
	StyleSheet
} from 'react-native';

export default function LocationRequiredContent() {
	return (
		<View style={styles.view}>
			<Text style={styles.text}>
				Please enable location services.
			</Text>
		</View>
	);
}

const styles = StyleSheet.create({
	view: {
		flex: 1,
		alignItems: 'center',
		justifyContent: 'center',
		padding: 8
	},
	text: {
	}
});
