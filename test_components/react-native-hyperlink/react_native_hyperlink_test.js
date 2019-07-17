import React from 'react'
import { Text, View, Linking, StyleSheet } from 'react-native'
import Hyperlink from 'react-native-hyperlink'

export default class react_native_hyperlink_test extends React.Component {
	render() {
		return (
			<View style={css.dependency_output}>
				<Hyperlink
					linkStyle={css.hyperlink}
					onPress={url => Linking.openURL(url)}
				>
					<View>
						<Text>Link:</Text>
						<Text>https://ucsd.edu/</Text>
					</View>
				</Hyperlink>
			</View>
		)
	}
}

const css = StyleSheet.create({
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
	hyperlink: { color: '#0d48a6', textDecorationLine: 'underline' }
})
