import React from 'react'
import {
	Alert,
	Platform,
} from 'react-native'
import { connect } from 'react-redux'
import firebase from 'react-native-firebase'
import Permissions from 'react-native-permissions'
import NavigationService from '../navigation/NavigationService'

class PushNotificationContainer extends React.Component {
	async componentDidMount() {
		this.checkPermission()

		this.onTokenRefreshListener = firebase.messaging().onTokenRefresh((fcmToken) => {
			/** Subscribe to topics **/
			this.props.refreshSubscriptions()

			/** If logged in, register token **/
			if (this.props.user.isLoggedIn) this.props.registerToken(fcmToken)
		})

		this.messageListener = firebase.messaging().onMessage((message) => {
			this.props.updateMessages(new Date().getTime())
		})

		// this runs when the app is in foreground and notification is received
		this.notificationListener = firebase.notifications().onNotification((notification) => {
			// body and title is available for android here
			this.props.updateMessages(new Date().getTime())
		})
		// this runs if app was in background or foreground and the notification was tapped
		this.notificationOpenedListener = firebase.notifications().onNotificationOpened((notificationOpen: firebase.NotificationOpen) => {
			const { notification } = notificationOpen
			const { routeName, params } = notification.data
			this.props.updateMessages(new Date().getTime())
			if (routeName) {
				NavigationService.navigate(routeName, params)
			} else {
				NavigationService.navigate('Messaging', params)
			}
			// body and title is available for android here
		})

		// this only runs if the app was compeltely closed (not in foreground or background) and the notification was tapped
		const notificationOpen: firebase.NotificationOpen = await firebase.notifications().getInitialNotification()
		if (notificationOpen) {
			// App was opened by a notification
			const { notification } = notificationOpen
			const { routeName, params } = notification.data
			this.props.updateMessages(new Date().getTime())
			NavigationService.navigate(routeName, params)
			if (routeName) {
				NavigationService.navigate(routeName, params)
			} else {
				NavigationService.navigate('Messaging', params)
			}
			// body and title is not available for android here
		}
	}

	componentWillUnmount() {
		this.onTokenRefreshListener()
		this.messageListener()
	}

	getNotificationToken = () => {
		firebase.messaging().getToken()
			.then((fcmToken) => {
				if (fcmToken) {
					/** Subscribe to topics **/
					this.props.refreshSubscriptions()
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
		// TODO: send token to server so we can push notifications here
	}

	render() {
		// TODO: render error message if user does not allow location
		return null
	}
}

function mapStateToProps(state, props) {
	return { user: state.user }
}

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		registerToken: (token) => {
			dispatch({ type: 'REGISTER_TOKEN', token })
		},
		updateMessages: () => {
			dispatch({ type: 'UPDATE_MESSAGES' })
		},
		refreshSubscriptions: () => {
			dispatch({ type: 'REFRESH_TOPIC_SUBSCRIPTIONS' })
		}
	}
)

module.exports = connect(mapStateToProps, mapDispatchToProps)(PushNotificationContainer)
