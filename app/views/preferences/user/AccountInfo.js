import React from 'react'
import {
	View,
	Text
} from 'react-native'
import { connect } from 'react-redux'

import Icon from 'react-native-vector-icons/MaterialIcons'
import Touchable from '../../common/Touchable'
import css from '../../../styles/css'

const AccountInfo = ({ username, doLogout }) => (
	<View style={css.ua_accountinfo}>
		<View style={css.ua_loggedin}>
			<Icon
				name="check-circle"
				size={26}
				style={css.ua_username_checkmark}
			/>
			<Text style={css.ua_username_text}>
				{username}
			</Text>
		</View>
		<View style={css.ua_logout}>
			<Touchable onPress={() => doLogout()}>
				<Text style={css.ua_loutout_text}>Log out</Text>
			</Touchable>
		</View>
	</View>
)

function mapStateToProps(state, props) {
	return { username: state.user.profile.username }
}

function mapDispatchToProps(dispatch) {
	return {
		doLogout: () => {
			dispatch({ type: 'USER_LOGOUT' })
		}
	}
}

export default connect(mapStateToProps, mapDispatchToProps)(AccountInfo)
