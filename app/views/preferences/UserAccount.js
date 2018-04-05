import React, { Component } from 'react';
import {
	View,
	Text,
	Linking,
	TouchableOpacity,
	TextInput
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';
import * as Keychain from 'react-native-keychain';

import { connect } from 'react-redux';
import getAuthenticationService from '../../services/authenticationService';
import css from '../../styles/css'
import Touchable from '../common/Touchable';
import Settings from '../../AppSettings';
import logger from '../../util/logger';
import { getMaxCardWidth } from '../../util/general';
import Card from '../card/Card';


const authenticationService = getAuthenticationService();

// View for user to manage account, sign-in or out
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
		if (!event.url.startsWith(Settings.USER_LOGIN.OPTIONS.REDIRECT_URL)) return;

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
			return this._renderAccountContainer(this.props.user.profile.name);
		} else {
			return this._renderAccountContainer('Tap to Log In');
		}
	}
	render() {
		if (Settings.USER_LOGIN.ENABLED === false) return null;

		return (
			<Card id="user" title="Account" hideMenu={true}>
				<View
					style={{ flexGrow: 1, width: getMaxCardWidth() }}
				>
					{(this.props.user.isLoggedIn) ? (
						<AccountInfo
							username={this.props.user.username}
							handleLogout={this.handleLogout}
						/>
					) :
					(
						<AccountLogin
							handleLogin={this.handleLogin}
						/>
					)}
				</View>
			</Card>
		);
	}
}

const AccountInfo = ({ username, handleLogout }) => (
	<TouchableOpacity
		style={css.UserAccount_infoContainer}
		onPress={handleLogout}
	>
		<Text
			style={css.UserAccount_text}
		>
			{username}
		</Text>
		<Icon
			name="sign-out"
			size={20}
		/>
	</TouchableOpacity>
);

const AccountLogin = ({ handleLogin }) => (
	<View
		style={css.UserAccount_loginContainer}
	>
		<TextInput
			style={css.UserAccount_input}
			placeholder="Username"
			returnKeyType="next"
			underlineColorAndroid="transparent"
			onChange={(event) => {
				this._usernameText = event.nativeEvent.text;
			}}
			onSubmitEditing={(event) => {
				this._passwordInput.focus();
			}}
		/>
		<TextInput
			ref={(c) => { this._passwordInput = c; }}
			style={css.UserAccount_input}
			placeholder="Password"
			returnKeyType="go"
			underlineColorAndroid="transparent"
			secureTextEntry
			onChange={(event) => {
				this._passwordText = event.nativeEvent.text;
			}}
			onSubmitEditing={(event) => {
				handleLogin(this._usernameText, event.nativeEvent.text);
			}}
		/>
		<Touchable
			onPress={() => console.log('Forgot password')}
			style={css.UserAccount_forgotButton}
		>
			<Text
				style={css.UserAccount_forgotText}
			>
				Forgot password?
			</Text>
		</Touchable>
		<Touchable
			onPress={() => handleLogin(this._usernameText, this._passwordText)}
			style={css.UserAccount_loginButton}
		>
			<Text
				style={css.UserAccount_loginText}
			>
				Login
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

module.exports = connect(mapStateToProps, mapDispatchToProps)(UserAccount)