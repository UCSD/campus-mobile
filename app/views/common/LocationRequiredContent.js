import React from 'react';
import {
	Text,
	View,
	StyleSheet,
	TouchableHighlight,
	Dimensions
} from 'react-native';
import { openSettings } from 'react-native-permissions';

const deviceWidth = Dimensions.get('window').width;

export default function LocationRequiredContent() {
	return (
		<View style={styles.view}>
			<Text style={styles.text}>
				Unable to access location services, please check settings.
			</Text>
			<TouchableHighlight
				onPress={
					() => openSettings()
				}
			>
				<View style={styles.settings_view}>
					<Text style={styles.settings_text}>
						Open Settings
					</Text>
				</View>
			</TouchableHighlight>
		</View>
	);
}

const styles = StyleSheet.create({
	view: {
		flex: 1,
		alignItems: 'center',
		padding: 8,
		width: deviceWidth
	},
	settings_view: {
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: '#17AADF',
		borderRadius: 3,
		marginTop: 20,
		padding: 10
	},
	settings_text: {
		color: '#FFF'
	}
});
