import React from 'react';
import {
	Text,
	View,
	TouchableHighlight,
	Dimensions
} from 'react-native';
import { openSettings } from 'react-native-permissions';

const css = require('../../styles/css');

export default function LocationRequiredContent() {
	return (
		<View style={css.lrc_container}>
			<Text style={css.lrc_settings_text}>
				Unable to access location services, please check settings.
			</Text>
			<TouchableHighlight
				onPress={
					() => openSettings()
				}
			>
				<View style={css.lrc_settings_view}>
					<Text style={css.lrc_settings_text}>
						Open Settings
					</Text>
				</View>
			</TouchableHighlight>
		</View>
	);
}