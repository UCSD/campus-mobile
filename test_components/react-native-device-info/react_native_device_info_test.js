import React from 'react'
import { Text, View, StyleSheet } from 'react-native'
import DeviceInfo from 'react-native-device-info'

export default class react_native_device_info_test extends React.Component {
	render() {
		const baseOS = DeviceInfo.getUniqueID()
		console.log(baseOS)
		return (
			<View style={css.dependency_output}>
				<Text> {baseOS}</Text>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})