import React from 'react'
import { Text, View, StyleSheet } from 'react-native'

const moment = require('moment')

export default class moment_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<Text>{moment().format('LLLL')}</Text>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
