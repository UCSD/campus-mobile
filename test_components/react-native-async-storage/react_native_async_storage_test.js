import React from 'react'
import { View, StyleSheet, Button } from 'react-native'
import AsyncStorage from '@react-native-community/async-storage'

export default class react_native_async_storage_test extends React.Component {
	render() {
		storeData
		return (
			<View style={css.dependency_output}>
				<Button
					onPress={storeData}
					title="test saving data"
					color="#841584"
				/>
				<Button
					onPress={getData}
					title="test getting data"
					color="#841584"
				/>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})

const storeData = async () => {
	try {
		await AsyncStorage.setItem('@storage_Key', '1234')
		alert('stored 1234')
	} catch (e) {
		alert('something went wrong')
	}
}

const getData = async () => {
	try {
		const value = await AsyncStorage.getItem('@storage_Key')
		if (value !== null) {
			alert('retrieve data: ' + value)
		}
	} catch (e) {
		alert('something went wrong')
	}
}