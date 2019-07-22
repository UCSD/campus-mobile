import React from 'react'
import { View, StyleSheet } from 'react-native'
import MapView, { PROVIDER_GOOGLE } from 'react-native-maps'

export default class react_native_maps_test extends React.Component {
	render() {
		return (
			<View style={styles.container}>
				{
					<MapView
						style={styles.map}
						region={
							{
								latitude: 37.78825,
								longitude: -122.4324,
								latitudeDelta: 0.0922,
								longitudeDelta: 0.0421,
							}
						}
					/>
				}
			</View>
		)
	}
}

const styles = StyleSheet.create({
	container: {
		...StyleSheet.absoluteFillObject,
		height: 400,
		width: 400,
		justifyContent: 'center',
		alignItems: 'center',
	},
	map: {
		...StyleSheet.absoluteFillObject,
	},
})

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
})
