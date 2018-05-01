import React, { Component } from 'react'
import {
	Alert,
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

		// if we're mounting and we're somehow still in the
		// process of logging in, check if we've timed out.
		// otherwise, set a timeout
		if (this.props.user.isLoggingIn) {
			const now = new Date()
			const lastPostTime = new Date(this.props.user.timeRequested)
			if (now - lastPostTime >= AppSettings.SSO_TTL) {
				this.props.timeoutLogin()
			} else {
				// timeout after remaining time expires
				setTimeout(this.props.timeoutLogin, now - lastPostTime)
			}
		}
	}

	componentWillReceiveProps(nextProps) {
		if (nextProps.user.isLoggedIn) {
			this.props.doTokenRefresh()
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

	handleLogin = (user, pass) => {
		if (!this.props.user.isLoggingIn) this.props.doLogin(user, pass)
	}

	handleLogout = () => {
		this.props.doLogout()
	}

	_renderAccountContainer = mainText => (
		<TouchableOpacity
			style={css.UserAccount_spacedRow}
			onPress={this._performUserAuthAction}
		>
			<Text style={css.UserAccount_accountText}>{mainText}</Text>
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
		const { error } = this.props.user
		if (error && !this.props.user.isLoggingIn) {
			Alert.alert(
				'Sign in error',
				error,
				[
					{ text: 'OK', onPress: () => { this.props.clearErrors() } }
				],
				{ cancelable: false }
			)
		}
		return (
			<Card id="user" title={this.props.user.isLoggedIn ? 'Logged in as:' : 'Log in with SSO:'} hideMenu={true}>
				<View style={{ width: getMaxCardWidth() }}>
					{(this.props.user.isLoggedIn) ? (
						<AccountInfo
							username={this.props.user.profile.username}
							handleLogout={this.handleLogout}
						/>
					) : (
						<AccountLogin
							handleLogin={this.handleLogin}
							error={this.props.user.error}
							isLoggingIn={this.props.user.isLoggingIn}
						/>
					)}
				</View>
			</Card>
		)
	}
}

function mapStateToProps(state, props) {
	return { user: state.user }
}

function mapDispatchToProps(dispatch) {
	return {
		doLogin: (username, password) => {
			dispatch({ type: 'USER_LOGIN', username, password })
		},
		doTokenRefresh: () => {
			dispatch({ type: 'USER_TOKEN_REFRESH' })
		},
		doLogout: () => {
			dispatch({ type: 'USER_LOGOUT' })
		},
		timeoutLogin: () => {
			dispatch({ type: 'USER_LOGIN_TIMEOUT' })
		},
		clearErrors: () => {
			dispatch({ type: 'USER_CLEAR_ERRORS' })
		}
	}
}

module.exports = connect(
	mapStateToProps,
	mapDispatchToProps
)(UserAccount)
