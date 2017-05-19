import React from 'react';
import {
	View,
} from 'react-native';

import UserAccount from './UserAccount';
import CardPreferences from './CardPreferences';
import css from '../../styles/css';

// View for user to manage preferences, including which cards are visible
const PreferencesView = () => (
	<View style={css.main_container}>
		<UserAccount />
		<CardPreferences />
	</View>
);
export default PreferencesView;
