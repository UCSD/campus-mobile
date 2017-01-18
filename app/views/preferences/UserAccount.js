import React, { Component } from 'react';
import {
	View,
	Text,
	Linking,
	TouchableOpacity,
} from 'react-native';

import { connect } from 'react-redux';
import Icon from 'react-native-vector-icons/FontAwesome';

import Settings from '../../AppSettings';
import Card from '../card/Card';
import css from '../../styles/css';

// View for user to manage account, sign-in or out
export default class UserAccount extends Component {
	componentDidMount() {
		console.log('listener added');
		Linking.addEventListener('url', this._handleOpenURL);
	}
	componentWillUnmount() {
		console.log('unmounted');
		Linking.removeEventListener('url', this._handleOpenURL);
	}
	_handleOpenURL(event) {
		console.log('OPENING URL');
		console.log(event.url);
		const openIdSettings = Settings.USER_LOGIN.OPTIONS;

		// TODO: get access_token, POST to userinfo endpoint to get back user info
		if (event.url.startsWith(openIdSettings.REDIRECT_URL)) {
			// only handle callback URLs, in case we deep link for other things
			const accessRegex = event.url.match(/access_token=([^&]*)/);
			const stateRegex = event.url.match(/state=([^&]*)/);

			if (accessRegex && stateRegex) {
				// first, verify the state regex is what we expected
				if (stateRegex[1] !== openIdSettings.STATE) {
					return; // just don't handle the event, though maybe log error?
				}

				const access_token = accessRegex[1]; // just get the value from the match group

				fetch(openIdSettings.USER_INFO_URL, {
					method: 'POST',
					headers: {
						'Authorization': `Bearer ${access_token}`,
					},
				})
				.then(result => result.json())
				.then(userInfo => {
					console.log(userInfo);
				})
				.catch(error => {}); // TODO: notify user if logon failed
			}
		}
	}
	_performUserAuthAction = () => {
		// TODO: for now, assume they want to log in
		const openIdSettings = Settings.USER_LOGIN.OPTIONS;

		const authUrl = [
			`${openIdSettings.AUTH_URL}`,
			'?response_type=id_token+token',
			`&client_id=${openIdSettings.CLIENT_ID}`,
			`&redirect_uri=${openIdSettings.REDIRECT_URL}`,
			'&scope=openid+profile+email',
			`&state=${openIdSettings.STATE}`,
			`&nonce=${Math.random().toString(36).slice(2)}`
		].join('');

		Linking.openURL(authUrl).catch(err => console.error('An error occurred', err));
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
			return this._renderAccountContainer('User Info TBD');
		} else {
			return this._renderAccountContainer('Tap to Log In');
		}
	}
	render() {
		if (Settings.USER_LOGIN.ENABLED === false) return null;

		return (
			<Card id="user" title="Account" hideMenu={true}>
				<View style={css.card_content_full_width}>
					<View style={css.column}>
						<View style={css.preferencesContainer}>
							{this._renderAccountInfo()}
						</View>
					</View>
				</View>
			</Card>
		);
	}
}

function mapStateToProps(state, props) {
	return {
		user: state.user,
	};
}

module.exports = connect(mapStateToProps)(UserAccount);
