import React from 'react'
import {
	View,
	Text
} from 'react-native'
import { connect } from 'react-redux'
import FAIcon from 'react-native-vector-icons/FontAwesome'

import Touchable from '../../common/Touchable'
import css from '../../../styles/css'

const AccountPanicked = ({ clearInvalidCredentialsError }) => (
	<View style={css.ua_loginContainer}>
		<FAIcon name="warning" style={css.ua_panicIcon} />
		<Text style={css.ua_panicText}>
			{'You have been logged out because your credentials could not be verified. Please try to log in again.'}
		</Text>
		<Touchable
			onPress={() => clearInvalidCredentialsError()}
			style={css.ua_loginButton}
		>
			<Text style={css.ua_loginText}>
				OK
			</Text>
		</Touchable>
	</View>
)

function mapStateToProps(state, props) {
	return { invalidSavedCredentials: state.user.invalidSavedCredentials }
}

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		clearInvalidCredentialsError: () => {
			dispatch({ type: 'CLEAR_INVALID_CREDS_ERROR' })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(AccountPanicked)
