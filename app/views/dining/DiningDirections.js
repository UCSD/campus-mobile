import React from 'react'
import {
	View,
	Text
} from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'

import { gotoNavigationApp } from '../../util/general'
import COLOR from '../../styles/ColorConstants'
import css from '../../styles/css'
import Touchable from '../common/Touchable'

const DiningDirections = ({ latitude, longitude, address, distance }) => (
	latitude !== 0 && longitude !== 0 ? (
		<Touchable
			onPress={() => {
				if (latitude && longitude) gotoNavigationApp(latitude, longitude)
				else if (address) gotoNavigationApp(null, null, address)
			}}
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
)

export default DiningDirections
