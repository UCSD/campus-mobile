import React from 'react'
import {
	View,
	Text
} from 'react-native'

import Icon from 'react-native-vector-icons/MaterialIcons'
import Touchable from '../../common/Touchable'
import css from '../../../styles/css'

const AccountInfo = ({ username, handleLogout }) => (
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
			<Touchable onPress={handleLogout}>
				<Text style={css.ua_loutout_text}>Log out</Text>
			</Touchable>
		</View>
	</View>
)

export default AccountInfo
