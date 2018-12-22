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
			/** Subscribe to topics **/
			this.props.refreshSubscriptions()

			/** If logged in, register token **/
			if (this.props.user.isLoggedIn) this.props.registerToken(fcmToken)
		})

		this.messageListener = firebase.messaging().onMessage((message) => {
			this.props.updateMessages()
		})

		this.notificationListener = firebase.notifications().onNotification((notification) => {
			this.props.updateMessages()
		})
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
		// When app launches, update messages for the first time
		this.props.updateMessages()

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
