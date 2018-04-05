import React from 'react'
import { View } from 'react-native'
import css from './styles/css'
import PushNotificationContainer from './containers/pushNotificationContainer'
import Router from './navigation/Router'

const Main = () => (
	<View style={css.main_container}>
		<PushNotificationContainer />
		<Router />
	</View>
)

export default Main
