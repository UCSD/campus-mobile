import React from 'react'
import { View, StyleSheet, Alert, Button } from 'react-native'
import Permissions from 'react-native-permissions'

export default class react_native_permissions_test extends React.Component {
	// Check the status of a single permission
	componentDidMount() {
		Permissions.check('photo').then(response => {
			// Response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			this.setState({ photoPermission: response })
		})
	}
	// Request permission to access photos
	_requestPermission = () => {
		Permissions.request('photo').then(response => {
			// Returns once the user has chosen to 'allow' or to 'not allow' access
			// Response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
			this.setState({ photoPermission: response })
			console.log(response)
		})
	}

	// This is a common pattern when asking for permissions.
	// iOS only gives you once chance to show the permission dialog,
	// after which the user needs to manually enable them from settings.
	// The idea here is to explain why we need access and determine if
	// the user will say no, so that we don't blow our one chance.
	// If the user already denied access, we can ask them to enable it from settings.
	_alertForPhotosPermission() {
		Alert.alert(
			'Can we access your photos?',
			'We need access so you can set your profile pic',
			[
				{
					text: 'No way',
					onPress: () => console.log('Permission denied'),
					style: 'cancel',
				},
				this.state.photoPermission === 'undetermined'
					? { text: 'OK', onPress: this._requestPermission }
					: { text: 'Open Settings', onPress: Permissions.openSettings },
			],
		)
	}

	render() {
		return (
			<View style={css.dependency_output}>
				<Button
					onPress={this._requestPermission}
					title="request permission"
					color="#841584"
				/>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
