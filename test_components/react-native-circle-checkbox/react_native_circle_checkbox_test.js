import React from 'react'
import { View, StyleSheet } from 'react-native'
import CircleCheckBox, { LABEL_POSITION } from 'react-native-circle-checkbox'

export default class react_native_circle_checkbox_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<CircleCheckBox
					checked={true}
					onToggle={checked => console.log('My state is: ', checked)}
					labelPosition={LABEL_POSITION.RIGHT}
					label="Checkbox example"
				/>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
