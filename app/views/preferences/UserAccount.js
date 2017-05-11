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

import { connect } from 'react-redux';
import { userLoggedIn, userLoggedOut } from '../../actions';
import getAuthenticationService from '../../services/authenticationService';

import Settings from '../../AppSettings';
import logger from '../../util/logger';
import { getMaxCardWidth } from '../../util/general';
import Card from '../card/Card';
import css from '../../styles/css';

const authenticationService = getAuthenticationService();

// View for user to manage account, sign-in or out
class UserAccount extends Component {
	componentDidMount() {
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

			Linking.openURL(authUrl).catch(err => logger.error('An error occurred', err));
		}
	}

	handleLogin = (user, pass) => {
		this.props.doLogin(user, pass);
	}

	handleLogout = () => {
		this.props.doLogout();
	}

	_renderAccountContainer = (mainText) => {
		return (
			<TouchableOpacity style={css.spacedRow} onPress={this._performUserAuthAction}>
				<View style={css.centerAlign}>
					<Text style={css.prefCardTitle}>{mainText}</Text>
				</View>
				<View style={css.centerAlign}>
					<Icon name="user" />
				</View>
			</TouchableOpacity>
		);
	}
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
			onSubmitEditing={(event) => {
				handleLogin(this._usernameText, event.nativeEvent.text);
			}}
		/>
	</View>
);

function mapStateToProps(state, props) {
	return {
		user: state.user,
	};
}

function mapDispatchToProps(dispatch) {
	return {
		doLogin: (user, pass) => {
			dispatch({ type: 'USER_LOGIN', user, pass });
		},
		doLogout: (user, pass) => {
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
	loginButton: { flexGrow: 1, height: 50, backgroundColor: '#034262', alignItems: 'center', justifyContent: 'center' },
	loginText: { fontSize: 18, color: '#F9F9F9' }
});

module.exports = connect(mapStateToProps, mapDispatchToProps)(UserAccount);
