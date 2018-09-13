import React from 'react'
import PropTypes from 'prop-types'
import { View } from 'react-native'
import Entypo from 'react-native-vector-icons/Entypo'
import FAIcon from 'react-native-vector-icons/FontAwesome'
import css from '../styles/css'
import COLOR from '../styles/ColorConstants'

const propTypes = {
	title: PropTypes.string.isRequired,
	focused: PropTypes.bool.isRequired,
}

const TabIcons = (props) => {
	let TabIcon

	if (props.title === 'Home') {
		TabIcon = () => (<Entypo name="home" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} />)
	} else if (props.title === 'Map') {
		TabIcon = () => (<Entypo name="location" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} />)
	} else if (props.title === 'Messaging') {
		TabIcon = () => (<FAIcon name="bell-o" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} />)
	} else if (props.title === 'Preferences') {
		TabIcon = () => (
			<View style={[css.tabIconUserOutline, props.focused ? { borderColor: COLOR.PRIMARY } : null]}>
				<Entypo
					style={[css.tabIconUser, props.focused ? { backgroundColor: COLOR.PRIMARY } : null]}
					name="user"
					size={24}
				/>
			</View>
		)
	}

	return (
		<View style={[css.tabContainer, props.focused ? css.tabContainerBottom : null]}>
			<TabIcon />
		</View>
	)
}

TabIcons.propTypes = propTypes
export default TabIcons
