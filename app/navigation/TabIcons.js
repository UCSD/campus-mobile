import React from 'react'
import PropTypes from 'prop-types'
import { View } from 'react-native'
import Entypo from 'react-native-vector-icons/Entypo'

import css from '../styles/css'
import COLOR from '../styles/ColorConstants'

const propTypes = {
	title: PropTypes.string.isRequired,
	focused: PropTypes.bool.isRequired,
}

const TabIcons = (props) => {
	let tabIconPack,
		tabIconName

	if (props.title === 'Home') {
		tabIconPack = 'Entypo'
		tabIconName = 'home'
	} else if (props.title === 'Map') {
		tabIconPack = 'Entypo'
		tabIconName = 'location'
	} else if (props.title === 'Feedback') {
		tabIconPack = 'Entypo'
		tabIconName = 'new-message'
	} else if (props.title === 'Preferences') {
		tabIconPack = 'Entypo'
		tabIconName = 'user'
	}

	return (
		<View style={[css.tabContainer, props.focused ? css.tabContainerBottom : null]}>
			{tabIconPack === 'Entypo' && tabIconName !== 'user' ? (
				<Entypo
					style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]}
					name={tabIconName}
					size={24}
				/>
			) : null }
			{tabIconPack === 'Entypo' && tabIconName === 'user' ? (
				<View
					style={[css.tabIconUserOutline, props.focused ? { borderColor: COLOR.PRIMARY } : null]}
				>
					<Entypo
						style={[css.tabIconUser, props.focused ? { backgroundColor: COLOR.PRIMARY } : null]}
						name={tabIconName}
						size={24}
					/>
				</View>
			) : null }
		</View>
	)
}

TabIcons.propTypes = propTypes
export default TabIcons
