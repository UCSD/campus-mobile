import React from 'react';
import {
	View,
	Text,
	StyleSheet
} from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';

import {
	gotoNavigationApp
} from '../../util/general';
import {
	COLOR_PRIMARY,
	COLOR_MGREY
} from '../../styles/ColorConstants';
import Touchable from '../common/Touchable';

const DiningDirections = ({ latitude, longitude, distance }) => (
	latitude !== 0 && longitude !== 0 ? (
		<Touchable
			onPress={() => gotoNavigationApp(latitude, longitude)}
			style={styles.buttonContainer}
		>
			<Text style={styles.directionsText}>Directions</Text>
			<View style={styles.iconContainer}>
				<Icon name="md-walk" size={32} color={COLOR_PRIMARY} />
				{distance ? (
					<Text style={styles.distText}>{distance}</Text>
				) : null }
			</View>
		</Touchable>
	) : null
);

const styles = StyleSheet.create({
	buttonContainer: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, margin: 6, padding: 6 },
	directionsText: { flex: 5, fontSize: 22, color: COLOR_PRIMARY },
	iconContainer: { flex: 1, flexDirection: 'column', alignItems: 'center', justifyContent: 'center' },
	distText: { color: COLOR_PRIMARY, fontSize: 11, fontWeight: '600' },
});

export default DiningDirections;
