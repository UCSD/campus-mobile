import React, { Component } from 'react';
import {
	View,
	Text,
	Linking,
	TouchableOpacity,
	StyleSheet,
	TextInput
} from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import * as Keychain from 'react-native-keychain';
import { connect } from 'react-redux';
import getAuthenticationService from '../../services/authenticationService';
import Touchable from '../common/Touchable';
import AppSettings from '../../AppSettings';
import logger from '../../util/logger';
import css from '../../styles/css';
import { getMaxCardWidth, openURL } from '../../util/general';
import Card from '../card/Card';

const authenticationService = getAuthenticationService();

class UserAccount extends Component {
	componentDidMount() {
		const serviceName = 'ucsdapp';

		/*
		TODO: Check for credentials and check if login is active, re-login if needed
		Keychain.getGenericPassword(serviceName).then((creds) => {
			console.log(JSON.stringify(creds));
		});
		*/
		Linking.addEventListener('url', this._handleOpenURL);
	}
	componentWillUnmount() {
		Linking.removeEventListener('url', this._handleOpenURL);
	}
	_handleOpenURL = (event) => {
		// only handle proper auth redirection urls
		if (!authenticationService) return;
		if (!event.url.startsWith(AppSettings.SSO.OPENID.OPTIONS.REDIRECT_URL)) return;

		authenticationService.handleAuthenticationCallback(event)
		.then(userInfo => {
			// now we have user info, save in redux and we are set
			/*this.props.dispatch(userLoggedIn({
				profile: userInfo
			}));*/
			this.props.doLogin();
		})
		.catch(error => {}); // TODO: notify user if logon failed?
	}
	_performUserAuthAction = () => {
		if (this.props.user.isLoggedIn) {
			//this.props.dispatch(userLoggedOut()); // log out user, destroy profile/auth info
			this.props.doLogout();
		} else {
			// if the are not logged in, log them in
			const authUrl = authenticationService.createAuthenticationUrl();

			Linking.openURL(authUrl).catch(err => logger.log('An error occurred performing UserAuthAction: ', err));
		}
	}

	handleLogin = (user, pass) => {
		this.props.doLogin(user, pass);
	}

	handleLogout = () => {
		this.props.doLogout();
	}

	_renderAccountContainer = (mainText) => (
		<TouchableOpacity
			style={css.ua_spacedRow}
			onPress={this._performUserAuthAction}
		>
			<Text style={css.ua_accountText}>{mainText}</Text>
			<Icon name='user' />
		</TouchableOpacity>
	);

	_renderAccountInfo = () => {
		// show the account info of logged in user, or not logged in
		if (this.props.user.isLoggedIn) {
			return this._renderAccountContainer(this.props.user.profile.name);
		} else {
			return this._renderAccountContainer('Tap to Log In');
		}
	}

	render() {
		return (
			<Card id={'user'} title={this.props.user.isLoggedIn ? 'Logged in as:' : 'Log in with SSO:'} hideMenu={true}>
				<View style={{ flexGrow: 1, width: getMaxCardWidth() }}>
					{(this.props.user.isLoggedIn) ? (
						<AccountInfo
							username={this.props.user.username}
							handleLogout={this.handleLogout}
						/>
					) : (
						<AccountLogin handleLogin={this.handleLogin} />
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
			name='sign-out'
			size={20}
		/>
	</TouchableOpacity>
);

const AccountLogin = ({ handleLogin }) => (
	<View
		style={css.ua_loginContainer}
	>
		<TextInput
			style={css.ua_input}
			placeholder='User ID / PID'
			returnKeyType='next'
			underlineColorAndroid='transparent'
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
			placeholder='Password / PAC'
			returnKeyType='go'
			underlineColorAndroid='transparent'
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
			style={css.ua_loginButton}
		>
			<Text style={css.ua_loginText}>
				Sign on
			</Text>
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
		doLogout: () => {
			dispatch({ type: 'USER_LOGOUT' });
		},
	};
}

module.exports = connect(mapStateToProps, mapDispatchToProps)(UserAccount);
