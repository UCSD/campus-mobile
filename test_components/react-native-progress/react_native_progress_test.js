import React from 'react'
import { View, StyleSheet } from 'react-native'
import * as Progress from 'react-native-progress'

export default class react_native_progress_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<Progress.Bar
					progress={.5}
					width={null}
					borderWidth={0}
					height={10}
				/>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
