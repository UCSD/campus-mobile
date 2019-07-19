import React from 'react'
import { View, StyleSheet, Text } from 'react-native'
import * as Keychain from 'react-native-keychain'

export default class react_native_keychain_test extends React.Component {
	async componentDidMount() {
		const returnText = await test()
		this.setState({ returnText })
	}
	render() {
		if (this.state && this.state.returnText) {
			return (
				<View style={css.dependency_output}>
					<Text> {this.state.returnText} </Text>
				</View>
			)
		} else {
			return (
				<View style={css.dependency_output}>
				</View>
			)
		}
	}
}

async function test() {
	const username = 'zuck'
	const password = 'poniesRgr8'
	// Store the credentials
	await Keychain.setGenericPassword(username, password)
	try {
	// Retrieve the credentials
		const credentials = await Keychain.getGenericPassword()
		if (credentials) {
			return 'Credentials successfully loaded for user ' + credentials.username
		} else {
			return 'No credentials stored'
		}
	} catch (error) {
		console.log('Keychain couldn\'t be accessed!', error)
	}
	await Keychain.resetGenericPassword()
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
