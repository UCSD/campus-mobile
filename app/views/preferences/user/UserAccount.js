import React, { Component } from 'react'
import {
	View,
	Text,
	Linking,
	TouchableOpacity
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'

import AccountInfo from './AccountInfo'
import AccountLogin from './AccountLogin'
import AppSettings from '../../../AppSettings'
import css from '../../../styles/css'
import { getMaxCardWidth } from '../../../util/general'
import Card from '../../common/Card'

const auth = require('../../../util/auth')

class UserAccount extends Component {
	componentDidMount() {
		Linking.addEventListener('url', this._handleOpenURL)
	}

	componentWillReceiveProps(nextProps) {
		if (nextProps.user.isLoggedIn) {
			auth.retrieveAccessToken()
				.then((token) => {
					console.log('User Data: ', this.props.user)
					console.log('Access Token: ', token)
				})
		}
	}

	componentWillUnmount() {
		Linking.removeEventListener('url', this._handleOpenURL)
	}

	_renderAccountContainer = mainText => (
		<TouchableOpacity
			style={css.ua_spacedRow}
			onPress={this._performUserAuthAction}
		>
			<Text style={css.ua_accountText}>{mainText}</Text>
			<Icon name="user" />
		</TouchableOpacity>
	);

	_renderAccountInfo = () => {
		// show the account info of logged in user, or not logged in
		if (this.props.user.isLoggedIn) {
			return this._renderAccountContainer(this.props.user.profile.name)
		} else {
			return this._renderAccountContainer('Tap to Log In')
		}
	}

	render() {
		return (
			<Card id="user" title={this.props.user.isLoggedIn ? 'Logged in as:' : 'Log in with SSO:'} hideMenu={true}>
				<View style={{ width: getMaxCardWidth() }}>
					{(this.props.user.isLoggedIn) ? (
						<AccountInfo />
					) : (
						<AccountLogin />
					)}
				</View>
			</Card>
		)
	}
}

function mapStateToProps(state, props) {
	return { user: state.user }
}

export default connect(mapStateToProps)(UserAccount)
