import React from 'react'
import { View, StyleSheet } from 'react-native'
import Barcode from 'react-native-barcode-builder'

export default class react_native_barcode_builder_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<Barcode value="Hello World" format="CODE128" />
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
