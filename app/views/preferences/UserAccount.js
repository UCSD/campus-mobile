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
	_performUserAuthAction = () => {
		// TODO: for now, assume they want to log in
		// TODO: create nonce
		const clientId = 'nowimplicit';
		const authUrl = [
			'https://auth-dev.ucdavis.edu/identity/connect/authorize',
			'?response_type=id_token token',
			// '&response_mode=form_post',
			`&client_id=${clientId}`,
			'&redirect_uri=nowmobile://cb',
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
