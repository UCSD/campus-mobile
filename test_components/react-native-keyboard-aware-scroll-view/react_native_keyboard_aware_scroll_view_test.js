import React from 'react'
import { View, StyleSheet, TextInput } from 'react-native'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'

export default class react_native_keyboard_aware_scroll_view_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<KeyboardAwareScrollView>
					<View>
						<TextInput />
					</View>
				</KeyboardAwareScrollView>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
