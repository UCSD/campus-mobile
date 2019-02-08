import React from 'react'
import { View, Text } from 'react-native'
import { connect } from 'react-redux'
import Entypo from 'react-native-vector-icons/Entypo'
import FAIcon from 'react-native-vector-icons/FontAwesome'
import css from '../styles/css'
import COLOR from '../styles/ColorConstants'

const TabIcons = (props) => {
	let TabIcon

	if (props.title === 'Home') {
		TabIcon = () => (<Entypo name="home" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} />)
	} else if (props.title === 'Map') {
		TabIcon = () => (<Entypo name="location" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} />)
	} else if (props.title === 'Messaging') {
		TabIcon = () => (
			<View style={css.tabIconWithBadge}>
				{!props.unreadMessages ? (
					<View style={css.tabIconBadge}>
						<Text style={css.tabIconBadgeCount} numberOfLines={1}>
							5
						</Text>
					</View>
				) : null }
				<FAIcon name="bell-o" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} />
			</View>
		)
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


function mapStateToProps(state, props) {
	return { unreadMessages: state.messages.unreadMessages }
}

export default connect(mapStateToProps)(TabIcons)
