import React from 'react'
import { View, StyleSheet, Button } from 'react-native'
import { Client } from 'bugsnag-react-native'

const bugsnag = new Client('api key')

export default class bugsnag_react_native_test extends React.Component {
	sendReport = () => {
		bugsnag.notify(new Error('error'))
	}

	render() {
		return (
			<View style={css.dependency_output}>
				<Button
					onPress={this.sendReport}
					title="Send test error"
					color="#841584"
				/>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
