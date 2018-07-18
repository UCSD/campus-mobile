import React from 'react'
import { Text } from 'react-native'
import { withNavigation } from 'react-navigation'
import Entypo from 'react-native-vector-icons/Entypo'
import Ionicon from 'react-native-vector-icons/Ionicons'
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
const PreferencesItem = ({ title, icon, link, style, navigation }) => (
	<Touchable
		onPress={() => { navigation.navigate(link) }}
		style={css.pi_container}
	>
		<Entypo name={icon} size={24} style={css.pi_icon} />
		<Text style={css.pi_title}>{title}</Text>
		<Ionicon name="ios-arrow-forward" size={24} style={css.pi_arrow} />
	</Touchable>
)

export default withNavigation(PreferencesItem)
