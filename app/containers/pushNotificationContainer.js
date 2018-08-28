import React from 'react'
import {
	Alert,
	Platform,
} from 'react-native'
import { connect } from 'react-redux'
import firebase from 'react-native-firebase'
import Permissions from 'react-native-permissions'

class PushNotificationContainer extends React.Component {
	componentDidMount() {
		this.checkPermission()

		this.onTokenRefreshListener = firebase.messaging().onTokenRefresh((fcmToken) => {
			// Process your token as required
			console.log('Firebase Token (refresh):', fcmToken)
		})

		this.messageListener = firebase.messaging().onMessage((message) => {
			console.log('New message received: ', message)
		})

		this.notificationListener = firebase.notifications().onNotification((notification) => {
 			console.log('New notification received: ', notification)
		})

		firebase.messaging().subscribeToTopic('emergency');
	}

	componentWillUnmount() {
		// stop listening for events
		this.onTokenRefreshListener()
		this.messageListener()
	}

	getNotificationToken = () => {
		firebase.messaging().getToken()
			.then((fcmToken) => {
				if (fcmToken) {
					console.log('Firebase Token: ', fcmToken)
				}
			})
	}

	getSoftPermission = () => {
		Alert.alert(
			'Allow this app to send you notifications?',
			'We need access so we can keep you informed.',
			[
				{
					text: 'No',
					onPress: () => {}
				},
				{
					text: 'Yes',
					onPress: this.getPermission
				}
			]
		)
	}

	getPermission = () => {
		Permissions.request('notification')
			.then((response) => {
				// if authorized, act
				if (response === 'authorized') {
					this.getNotificationToken()
				}
			})
	}

	showLocalNotification = (notif) => {
		// NOTE: will not work until we configure local notifications
		if (notif && notif.notification) {

		}
	}

	checkPermission = () => {
		if (Platform.OS === 'ios') {
			// check for permission and either ask for it
			// or if we already have it then update the device tokens
			Permissions.check('notification')
				.then((response) => {
					if (response === 'undetermined') {
						this.getPermission()
					} else if (response === 'authorized') {
						this.getNotificationToken()
					}
				})
		} else {
			// android always has permissions, just go get the notification token
			this.getNotificationToken()
		}
	}

	// Set device information along with app push ID token
	updateServerToken = (token) => {
		console.log('push token', token)

		// TODO: send token to server so we can push notifications here
	}

	render() {
		return null // TODO: render error message if user does not allow location
	}
}

function mapStateToProps(state, props) {
	return {}
}

module.exports = connect(mapStateToProps)(PushNotificationContainer)
