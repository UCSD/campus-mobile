import React, { Component } from 'react';
import {
	Alert,
	View,
	Text,
	Linking,
	ActivityIndicator,
	TouchableOpacity,
	TextInput
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import { connect } from 'react-redux';
import Touchable from '../common/Touchable';
import AppSettings from '../../AppSettings';
import css from '../../styles/css';
import { getMaxCardWidth, openURL } from '../../util/general';
import Card from '../card/Card';

const auth = require('../../util/auth');

class UserAccount extends Component {
	componentDidMount() {
		Linking.addEventListener('url', this._handleOpenURL);
	}

	componentWillReceiveProps(nextProps) {
		if (nextProps.user.isLoggedIn) {
			this.props.doTokenRefresh();
			auth.retrieveAccessToken()
				.then((token) => {
					console.log('User Data: ', this.props.user);
					console.log('Access Token: ', token);
				});
		}
	}

	componentWillUnmount() {
		Linking.removeEventListener('url', this._handleOpenURL);
	}

	handleLogin = (user, pass) => {
		if (!this.props.user.isLoggingIn) this.props.doLogin(user, pass);
	}

	handleLogout = () => {
		this.props.doLogout();
	}

	render() {
		const { error } = this.props.user;
		if (error && !this.props.user.isLoggingIn) {
			Alert.alert(
				'Sign in error',
				error,
				[
					{ text: 'OK', onPress: () => { this.props.clearErrors(); } }
				],
				{ cancelable: false }
			);
		}
		return (
			<Card id="user" title={this.props.user.isLoggedIn ? 'Logged in as:' : 'Log in with SSO:'} hideMenu={true}>
				<View style={{ flexGrow: 1, width: getMaxCardWidth() }}>
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
		);
	}
}

const AccountInfo = ({ username, handleLogout }) => (
	<TouchableOpacity
		style={css.ua_infoContainer}
		onPress={handleLogout}
	>
		<Text
			style={css.ua_text}
		>
			{username}
		</Text>
		<Icon
			name="sign-out"
			size={20}
		/>
	</TouchableOpacity>
);

const AccountLogin = ({ handleLogin, error, isLoggingIn }) => (
	<View
		style={css.ua_loginContainer}
	>
		<TextInput
			style={css.ua_input}
			placeholder="User ID"
			returnKeyType="next"
			autoCapitalize="none"
			autoCorrect={false}
			underlineColorAndroid="transparent"
			editable={!isLoggingIn}
			onChange={(event) => {
				this._usernameText = event.nativeEvent.text;
			}}
			onSubmitEditing={(event) => {
				this._passwordInput.focus();
			}}
		/>
		<TextInput
			ref={(c) => { this._passwordInput = c; }}
			style={css.ua_input}
			placeholder="Password"
			returnKeyType="send"
			underlineColorAndroid="transparent"
			editable={!isLoggingIn}
			secureTextEntry
			onChange={(event) => {
				this._passwordText = event.nativeEvent.text;
			}}
			onSubmitEditing={(event) => {
				handleLogin(this._usernameText, event.nativeEvent.text);
			}}
		/>
		<Touchable
			onPress={() => handleLogin(this._usernameText, this._passwordText)}
			disabled={isLoggingIn}
			style={
				(isLoggingIn) ?
					(
						[css.ua_loginButton, css.ua_loginButtonDisabled]
					) : (
						css.ua_loginButton
					)
			}
		>
			<Text style={css.ua_loginText}>
				{
					(isLoggingIn) ?
						('Signing in...') :
						('Sign in')
				}
			</Text>
			{
				(isLoggingIn) ?
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
);

function mapStateToProps(state, props) {
	return {
		user: state.user,
	};
}

function mapDispatchToProps(dispatch) {
	return {
		doLogin: (username, password) => {
			dispatch({ type: 'USER_LOGIN', username, password });
		},
		doTokenRefresh: () => {
			dispatch({ type: 'USER_TOKEN_REFRESH' });
		},
		doLogout: () => {
			dispatch({ type: 'USER_LOGOUT' });
		},
		clearErrors: () => {
			dispatch({ type: 'USER_CLEAR_ERRORS' });
		}
	};
}

module.exports = connect(
	mapStateToProps,
	mapDispatchToProps
)(UserAccount);
