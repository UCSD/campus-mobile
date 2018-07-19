import React, { Component } from 'react'
import { ScrollView } from 'react-native'
import UserAccount from './user/UserAccount'
import CardPreferences from './card/CardPreferences'
import PreferencesItem from './PreferencesItem'

// View for user to manage preferences, including which cards are visible
class PreferencesView extends Component {
	static navigationOptions = { title: 'User Profile' }

	constructor(props) {
		super(props)
		this.state = { scrollEnabled: true }
	}

	toggleScroll = () => {
		this.setState({ scrollEnabled: !this.state.scrollEnabled })
	}

	render() {
		return (
			<ScrollView scrollEnabled={this.state.scrollEnabled}>
				<UserAccount />
				<CardPreferences toggleScroll={this.toggleScroll} />
				<PreferencesItem title="Feedback" icon="new-message" link="Feedback" />
			</ScrollView>
		)
	}
}

export default PreferencesView
