import React from 'react'
import { View, StyleSheet } from 'react-native'
import Icon from 'react-native-vector-icons/FontAwesome'

export default class react_native_vector_icons_test extends React.Component {
	render() {
		const myIcon = <Icon name="facebook" size={30} color="#900" />
		return (
			<View style={css.dependency_output}>
				{myIcon}
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
