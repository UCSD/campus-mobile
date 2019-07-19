import React from 'react'
import { View, StyleSheet } from 'react-native'
import RNExitApp from 'react-native-exit-app'

export default class react_native_exit_app_test extends React.Component {
	render() {
		RNExitApp.exitApp()
		return (
			<View style={css.dependency_output}>
				{/*insert test component here*/}
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
