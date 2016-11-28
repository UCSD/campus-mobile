import React from 'react';
import {
	Text,
	View,
	TouchableHighlight,
	Dimensions
} from 'react-native';
import { openSettings } from 'react-native-permissions';
import Icon from 'react-native-vector-icons/FontAwesome';

const css = require('../../styles/css');

export default function LocationRequiredContent() {
	return (
		<View style={css.lrc_container}>
			<View style={css.lrc_text_row}>
				<Icon style={css.lrc_warn_icon} name={'warning'} size={16} color={'rgba(0,0,0,.5)'} />
				<Text style={css.lrc_text}>To use this feature please enable Location Services</Text>
			</View>
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => openSettings()}>
				<View style={css.lrc_button}>
					<Text style={css.lrc_button_text}>
						Open Location Services
					</Text>
				</View>
			</TouchableHighlight>
		</View>
	);
}