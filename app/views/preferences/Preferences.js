import React from 'react'
import { ScrollView } from 'react-native'
import UserAccount from './user/UserAccount'
import PreferencesItem from './PreferencesItem'
import AppSettings from '../../AppSettings'

const PreferencesView = () => (
	<ScrollView>
		<UserAccount />
		<PreferencesItem title="Notifications" iconPack="FontAwesome" icon="bell-o" linkType="internal" link="Notifications" />
		<PreferencesItem title="Cards" iconPack="MaterialIcons" icon="reorder" linkType="internal" link="CardPreferences" />
		<PreferencesItem title="Feedback" iconPack="Entypo" icon="new-message" linkType="internal" link="Feedback" />
		<PreferencesItem title="Privacy Policy" iconPack="Feather" icon="lock" linkType="external" link={AppSettings.PRIVACY_POLICY_URL} />
	</ScrollView>
)

export default PreferencesView
