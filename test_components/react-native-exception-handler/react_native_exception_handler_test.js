import React from 'react'
import { View, StyleSheet, Alert } from 'react-native'
import { setJSExceptionHandler, getJSExceptionHandler } from 'react-native-exception-handler'

export default class react_native_exception_handler_test extends React.Component {
	render() {
		setJSExceptionHandler((exceptionhandler, allowInDevMode) => {})
		setJSExceptionHandler(errorHandler, true)
		const currentHandler = getJSExceptionHandler()
		console.log(currentHandler)
		return (
			<View style={css.dependency_output}>
				{this.test()}
			</View>
		)
	}
}

const errorHandler = (e, isFatal) => {
	if (isFatal) {
		Alert.alert(
			'Unexpected error occurred',
			`
		Error: ${(isFatal) ? 'Fatal:' : ''} ${e.name} ${e.message}
		We have reported this to our team ! Please close the app and start again!
		`,
			[{
				text: 'Close'
			}]
		)
	} else {
		console.log(e) // So that we can see it in the ADB logs in case of Android if needed
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
