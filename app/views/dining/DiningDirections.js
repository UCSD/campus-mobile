import React from 'react';
import {
	View,
	Text
} from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';

import {
	gotoNavigationApp
} from '../../util/general';
import {
	COLOR_PRIMARY,
} from '../../styles/ColorConstants';
import css from '../../styles/css';
import Touchable from '../common/Touchable';

const DiningDirections = ({ latitude, longitude, distance }) => (
	latitude !== 0 && longitude !== 0 ? (
		<Touchable
			onPress={() => gotoNavigationApp(latitude, longitude)}
			style={css.dd_directions_button_container}
		>
			<Text style={css.dd_directions_text}>Directions</Text>
			<View style={css.dd_directions_icon_container}>
				<Icon name="md-walk" size={32} color={COLOR_PRIMARY} />
				{distance ? (
					<Text style={css.dd_directions_distance_text}>{distance}</Text>
				) : null }
			</View>
		</Touchable>
	) : null
);

export default DiningDirections;
