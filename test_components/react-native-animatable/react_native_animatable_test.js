import React from 'react'
import { View, StyleSheet } from 'react-native'
import * as Animatable from 'react-native-animatable'

export default class react_native_animatable_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<Animatable.Text animation="zoomIn" duration={2000} iterationCount="infinite">Zoom in animation test</Animatable.Text>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
