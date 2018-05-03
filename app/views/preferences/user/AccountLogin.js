import React, { Component } from 'react'
import {
	Alert,
	View,
	Text,
	TextInput,
	ActivityIndicator
} from 'react-native'
import { connect } from 'react-redux'

import AppSettings from '../../../AppSettings'
import Touchable from '../../common/Touchable'
import css from '../../../styles/css'
import { openURL } from '../../../util/general'

class AccountLogin extends Component {
	constructor(props) {
		super(props)
		this.state = {
			credentials: {
				username: '',
				password: ''
			}
		}
	}

	componentDidMount() {
		// if we're mounting and we're somehow still in the
		// process of logging in, check if we've timed out.
		// otherwise, set a timeout
		if (this.props.requestStatus) {
			const now = new Date()
			const lastPostTime = new Date(this.props.requestStatus.timeRequested)
			if (now - lastPostTime >= AppSettings.SSO_TTL) {
				this.props.timeoutLogin()
			} else {
				// timeout after remaining time expires
				setTimeout(this.props.timeoutLogin, now - lastPostTime)
			}
		}
	}

	componentDidUpdate(prevProps, prevState) {
		const oldStatus = prevProps.requestStatus
		const newStatus = this.props.requestStatus

		// Only render alerts if status change is new
		if (oldStatus !== newStatus) {
			// Failed log in
			if (this.props.requestError) {
				Alert.alert(
					'Sign in error',
					this.props.requestError,
					{ cancelable: false }
				)
			}
		}
	}

	handleCredentialInput = fieldName => (e) => {
		const { username, password } = this.state.credentials
		const newCredentials = { username, password }
		newCredentials[fieldName] = e.nativeEvent.text

		this.setState({ credentials: newCredentials })
	}

	render() {
		const { username, password } = this.state.credentials
		return (
			<View
				style={css.ua_loginContainer}
			>
				<TextInput
					style={css.ua_input}
					value={username}
					placeholder="User ID"
					returnKeyType="next"
					autoCapitalize="none"
					autoCorrect={false}
					underlineColorAndroid="transparent"
					editable={!this.props.requestStatus}
					onChange={this.handleCredentialInput('username')}
					onSubmitEditing={(event) => {
						this._passwordInput.focus()
					}}
				/>
				<TextInput
					ref={(c) => { this._passwordInput = c }}
					style={css.ua_input}
					value={password}
					placeholder="Password"
					returnKeyType="send"
					underlineColorAndroid="transparent"
					editable={!this.props.requestStatus}
					secureTextEntry
					onChange={this.handleCredentialInput('password')}
					onSubmitEditing={() => this.props.doLogin(username, password)}
				/>
				<Touchable
					onPress={() => this.props.doLogin(username, password)}
					disabled={Boolean(this.props.requestStatus)}
					style={
						(this.props.requestStatus) ?
							(
								[css.ua_loginButton, css.ua_loginButtonDisabled]
							) : (
								css.ua_loginButton
							)
					}
				>
					<Text style={css.ua_loginText}>
						{
							(this.props.requestStatus) ?
								('Signing in...') :
								('Sign in')
						}
					</Text>
					{
						(this.props.requestStatus) ?
							(
								<ActivityIndicator
									size="small"
									style={css.ua_loading_icon}
									color="#fff"
								/>
							) : (null)
					}
				</Touchable>

				<Touchable
					onPress={() => openURL(AppSettings.FORGOT_PASSWORD_URL)}
					style={css.ua_forgotButton}
				>
					<Text style={css.ua_forgotText}>
						Forgot your password?
					</Text>
				</Touchable>
			</View>
		)
	}
}

function mapStateToProps(state, props) {
	return {
		requestStatus: state.requestStatuses.LOG_IN,
		requestError: state.requestErrors.LOG_IN
	}
}

function mapDispatchToProps(dispatch) {
	return {
		doLogin: (username, password) => {
			dispatch({ type: 'USER_LOGIN', username, password })
		},
		timeoutLogin: () => {
			dispatch({ type: 'USER_LOGIN_TIMEOUT' })
		}
	}
}

export default connect(mapStateToProps, mapDispatchToProps)(AccountLogin)
