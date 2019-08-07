import React from 'react'
import { Text, View } from 'react-native'
import Icon from 'react-native-vector-icons/FontAwesome'

import css from '../../styles/css'

const LocationRequiredContent = () => (
	<View style={css.lrc_container}>
		<View style={css.lrc_textRow}>
			<Icon style={css.lrc_icon} name="warning" size={16} />
			<Text style={css.lrc_promptText}>To use this feature please enable Location Services</Text>
		</View>
	</View>
)

export default LocationRequiredContent
