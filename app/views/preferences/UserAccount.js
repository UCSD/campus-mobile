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

		// TODO: get access_token, POST to userinfo endpoint to get back user info
		if (event.url.startsWith('nowmobile://cb')) {
			// only handle callback URLs, in case we deep link for other things
			const accessRegex = event.url.match(/access_token=([^&]*)/);

			if (accessRegex) {
				const access_token = accessRegex[1]; // just get the value from the match group

				// fetch('https://auth-dev.ucdavis.edu/identity/connect/userinfo')
			}
		}
	}
	_performUserAuthAction = () => {
		// TODO: for now, assume they want to log in
		// TODO: nonce I don't think is needed, but we might want state to verify origination
		const clientId = 'nowimplicit';
		const authUrl = [
			'https://auth-dev.ucdavis.edu/identity/connect/authorize',
			'?response_type=id_token+token',
			`&client_id=${clientId}`,
			'&redirect_uri=nowmobile://cb',
			'&scope=openid+profile+email',
			'&nonce=1234'
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
