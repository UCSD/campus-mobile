import React from 'react'
import { View, StyleSheet, Text, Button, Platform } from 'react-native'
import firebase from 'react-native-firebase'
import Permissions from 'react-native-permissions'


export default class react_native_firebase_test extends React.Component {
	getNotificationToken = () => {
		firebase.messaging().getToken()
			.then((fcmToken) => {
				if (fcmToken) {
					/** Subscribe to topics **/
					console.log(fcmToken)
					this.setState({ token: fcmToken })
				}
			})
	}

	getPermission = () => {
		firebase.messaging().requestPermission()
			.then(() => {
				// User has authorised
				this.getNotificationToken()
			})
			.catch((error) => {
				// User has rejected permissions
				console.log('permission was rejected')
			})
	}

	// checkPermission = () => {
	// 	firebase.messaging().hasPermission()
	// 		.then((enabled) => {
	// 			if (enabled) {
	// 				// user has permissions
	// 				this.getNotificationToken()
	// 			} else {
	// 				// user doesn't have permission
	// 				this.getPermission()
	// 			}
	// 		})
	// }

	render() {
		const Analytics = firebase.analytics()
		Analytics.setAnalyticsCollectionEnabled(true)
		Analytics.setCurrentScreen('test screen1', 'test')
		Analytics.logEvent('product_view', {
			id: '123456789',
			color: 'red',
			via: 'ProductCatalog',
		})
		return (
			<View style={css.dependency_output}>
				<Button
					onPress={this.getPermission}
					title="get token"
					color="#841584"
				/>
				<Text>
					{this.state ? this.state.token : 'token was not fetched'}
				</Text>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
