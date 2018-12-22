import React, { Component } from 'react'
import { ScrollView } from 'react-native'
import UserAccount from './user/UserAccount'
import PreferencesItem from './PreferencesItem'
import AppSettings from '../../AppSettings'

class PreferencesView extends Component {
	static navigationOptions = { title: 'User Profile' }

	render() {
		return (
			<ScrollView>
				<UserAccount />
				<PreferencesItem title="Notifications" iconPack="FontAwesome" icon="bell-o" linkType="internal" link="Notifications" />
				<PreferencesItem title="Cards" iconPack="MaterialCommunityIcons" icon="cards-variant" linkType="internal" link="CardPreferences" />
				<PreferencesItem title="Feedback" iconPack="Entypo" icon="new-message" linkType="internal" link="Feedback" />
				<PreferencesItem title="Privacy Policy" iconPack="Feather" icon="lock" linkType="external" link={AppSettings.PRIVACY_POLICY_URL} />
			</ScrollView>
		)
	}
}

export default PreferencesView
