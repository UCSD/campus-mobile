import React from 'react'
import PropTypes from 'prop-types'
import { View, Text } from 'react-native'
import { connect } from 'react-redux'
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
		if (props.hasUnreadMsgs) {
			TabIcon = () => (<View style={styles.badgeIconView}><View style={styles.badge}><Text style={styles.badgeNumber}>2</Text></View><FAIcon name="bell-o" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} /></View>)
		}
		else {
			TabIcon = () => (<FAIcon name="bell-o" size={24} style={[css.tabIcon, props.focused ? { color: COLOR.PRIMARY } : null]} />)
		}
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

const styles = {
	badgeIconView: {
		position: 'relative',
		padding: 5
	},
	badge: {
		position: 'absolute',
		zIndex: 10,
		top: 1,
		right: 5,
		padding: 1,
		width: 15,
		height: 15,
		backgroundColor: 'red',
		borderRadius: 15 / 2,
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center'
	},
	badgeNumber: {
		color: 'white',
		position: 'absolute',
		textAlignVertical: 'center',
		textAlign: 'center'
	}
}

function mapStateToProps(state, props) {
	return { hasUnreadMsgs: state.messages.hasUnreadMsgs }
}

TabIcons.propTypes = propTypes
export default connect(mapStateToProps)(TabIcons)
