import React from 'react'
import { ScrollView } from 'react-native'
import { connect } from 'react-redux'

import css from '../../../styles/css'
import UserAccount from './UserAccount'

const LoginView = ({ isLoggedIn }) => (
	<ScrollView
		style={css.loginview_container}
		keyboardShouldPersistTaps="handled"
	>
		<UserAccount />
	</ScrollView>
)

function mapStateToProps(state) {
	return { isLoggedIn: state.user.isLoggedIn }
}

export default connect(mapStateToProps)(LoginView)
