import React from 'react'
import { Text, View, StyleSheet } from 'react-native'

const dateformat = require('dateformat')

export default class dateformat_test extends React.Component {
	render() {
		const now = new Date()
		return (
			<View style={css.dependency_output}>
				<Text>{dateformat(now)}</Text>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
