import React, { Component } from 'react'
import {
	View,
	Text,
	TextInput,
	ActivityIndicator
} from 'react-native'

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
					editable={!this.props.isLoggingIn}
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
					editable={!this.props.isLoggingIn}
					secureTextEntry
					onChange={this.handleCredentialInput('password')}
					onSubmitEditing={() => this.props.handleLogin(username, password)}
				/>
				<Touchable
					onPress={() => this.props.handleLogin(username, password)}
					disabled={this.props.isLoggingIn}
					style={
						(this.props.isLoggingIn) ?
							(
								[css.ua_loginButton, css.ua_loginButtonDisabled]
							) : (
								css.ua_loginButton
							)
					}
				>
					<Text style={css.ua_loginText}>
						{
							(this.props.isLoggingIn) ?
								('Signing in...') :
								('Sign in')
						}
					</Text>
					{
						(this.props.isLoggingIn) ?
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

export default AccountLogin
