import React from 'react'
import { View, StyleSheet } from 'react-native'
import Toast from 'react-native-simple-toast'

export default class react_native_simple_toast_test extends React.Component {
	render() {
		showToast()
		return (
			<View style={css.dependency_output}>
			</View>
		)
	}
}

const showToast = () => {
	Toast.show('This is a toast.')
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
