import React from 'react';
import {
	ScrollView,
} from 'react-native';

import CardPreferences from './CardPreferences';
import css from '../../styles/css';

// View for user to manage preferences, including which cards are visible
class PreferencesView extends React.Component {
	static navigationOptions = {
		title: 'User Settings',
	}

	constructor(props) {
		super(props);
		this.state = {
			scrollEnabled: true
		};
	}

	toggleScroll = () => {
		this.setState({ scrollEnabled: !this.state.scrollEnabled });
	}

	render() {
		return (
			<ScrollView
				style={css.main_container}
				scrollEnabled={this.state.scrollEnabled}
			>
				<CardPreferences
					toggleScroll={this.toggleScroll}
				/>
			</ScrollView>
		);
	}
}

export default PreferencesView;
