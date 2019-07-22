import React from 'react'
import { View, StyleSheet } from 'react-native'
import RNRestart from 'react-native-restart'

export default class react_native_restart_test extends React.Component {
	render() {
		RNRestart.Restart()
		return (
			<View style={css.dependency_output}>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
