import React from 'react'
import { Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import Entypo from 'react-native-vector-icons/Entypo'
import FontAwesome from 'react-native-vector-icons/FontAwesome'
import Ionicons from 'react-native-vector-icons/Ionicons'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

/**
 * Row item for user preferences
 * @param  {String} title Title to display
 * @param {String} icon Icon to display
 * @param {String} link Where to navigate to
 * @param {Object} style Optional style
 * @return {JSX} Return PreferencesItem JSX
 */
const PreferencesItem = ({ title, iconPack, icon, link, style, navigation }) => (
	<Touchable
		onPress={() => { navigation.navigate(link) }}
		style={css.pi_container}
	>
		{iconPack === 'Entypo' ? (
			<Entypo name={icon} size={24} style={css.pi_icon} />
		) : null }

		{iconPack === 'FontAwesome' ? (
			<FontAwesome name={icon} size={24} style={css.pi_icon} />
		) : null }

		<Text style={css.pi_title}>{title}</Text>
		<Ionicons name="ios-arrow-forward" size={24} style={css.pi_arrow} />
	</Touchable>
)

export default withNavigation(PreferencesItem)
