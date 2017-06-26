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
import { userLoggedIn, userLoggedOut } from '../../actions';
import getAuthenticationService from '../../services/authenticationService';

import Touchable from '../common/Touchable';
import Settings from '../../AppSettings';
import logger from '../../util/logger';
import { getMaxCardWidth } from '../../util/general';
import Card from '../card/Card';
import {
	COLOR_DGREY,
	COLOR_PRIMARY,
	COLOR_WHITE,
} from '../../styles/ColorConstants';

const authenticationService = getAuthenticationService();

// View for user to manage account, sign-in or out
class UserAccount extends Component {
	componentDidMount() {
		const serviceName = 'ucsdapp';

		Keychain.getGenericPassword(serviceName).then((creds) => {
			console.log(JSON.stringify(creds));
		});
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
			this.props.dispatch(userLoggedIn({
				profile: userInfo
			}));
		})
		.catch(error => {}); // TODO: notify user if logon failed?
	}
	_performUserAuthAction = () => {
		if (this.props.user.isLoggedIn) {
			this.props.dispatch(userLoggedOut()); // log out user, destroy profile/auth info
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
			style={styles.spacedRow}
			onPress={this._performUserAuthAction}
		>
			<Text style={styles.accountText}>{mainText}</Text>
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
		style={styles.infoContainer}
		onPress={handleLogout}
	>
		<Text
			style={styles.text}
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
		style={styles.loginContainer}
	>
		<TextInput
			style={styles.input}
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
			style={styles.input}
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
			onPress={() => console.log('whatever')}
			style={styles.forgotButton}
		>
			<Text
				style={styles.forgotText}
			>
				Forgot password?
			</Text>
		</Touchable>
		<Touchable
			onPress={() => handleLogin(this._usernameText, this._passwordText)}
			style={styles.loginButton}
		>
			<Text
				style={styles.loginText}
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

const styles = StyleSheet.create({
	text: { flex: 1, fontSize: 18 },
	icon: { flex: 1 },
	infoContainer: { flexGrow: 1, flexDirection: 'row', margin: 7 },
	loginContainer: { flexGrow: 1, margin: 7 },
	input: { flexGrow: 1, height: 50 },
	spacedRow: { flexDirection: 'row', justifyContent: 'space-between' },
	accountText: { textAlign: 'center', fontSize: 16, color: COLOR_DGREY },
	forgotButton: { flex: 1, justifyContent: 'center', alignItems: 'center', borderRadius: 3, padding: 10, },
	loginButton: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, padding: 10, },
	forgotText: { fontSize: 16, color: COLOR_PRIMARY },
	loginText: { fontSize: 16, color: COLOR_WHITE },
});

module.exports = connect(mapStateToProps, mapDispatchToProps)(UserAccount);
