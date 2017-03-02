import React, { Component } from 'react';
import {
	View,
	ScrollView
} from 'react-native';

import UserAccount from './UserAccount';
import CardPreferences from './CardPreferences';
import css from '../../styles/css';

// View for user to manage preferences, including which cards are visible
export default class PreferencesView extends Component {
	render() {
		return (
			<View style={css.main_container}>
				<ScrollView contentContainerStyle={css.scroll_default}>
					<UserAccount />
					<CardPreferences />
				</ScrollView>
			</View>
		);
	}
}
