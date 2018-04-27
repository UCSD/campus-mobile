import React from 'react';
import {
	Text,
	View,
	StyleSheet
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';

import Touchable from './Touchable';
import {
	WINDOW_WIDTH
} from '../../styles/LayoutConstants';
import {
	COLOR_PRIMARY,
	COLOR_WHITE,
	COLOR_DGREY
} from '../../styles/ColorConstants';

/* Currently unused due to API changes to react-native-permissions
const settingsPrompt = (
	<Touchable
		onPress={() => openSettings()}
		style={styles.button}
	>
		<Text style={styles.buttonText}>
			Open Location Services
		</Text>
	</Touchable>
);
*/

const LocationRequiredContent = () => (
	<View style={styles.container}>
		<View style={styles.textRow}>
			<Icon style={styles.icon} name={'warning'} size={16} />
			<Text style={styles.promptText}>To use this feature please enable Location Services</Text>
		</View>
	</View>
);

const styles = StyleSheet.create({
	icon: { color: COLOR_DGREY },
	container: { flex: 1, alignItems: 'center', padding: 8, width: WINDOW_WIDTH },
	textRow: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingTop: 10 },
	promptText: { fontSize: 14, color: COLOR_DGREY, paddingLeft: 6 },
	button: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, marginTop: 14, padding: 10 },
	buttonText: { color: COLOR_WHITE },
});

export default LocationRequiredContent;
