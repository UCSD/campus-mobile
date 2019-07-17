import React from 'react'
import { View, StyleSheet } from 'react-native'
// import module here
export default class template_test extends React.Component {
	render() {
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
