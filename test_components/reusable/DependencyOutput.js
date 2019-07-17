import React from 'react'
import { View, Text, StyleSheet, Linking, Button } from 'react-native'
import Hyperlink from 'react-native-hyperlink'

import NavigationService from '../react-navigation/NavigationService'


const DependencyOutput = ({ moduleName, moduleLink, moduleVersion, moduleVersionLink, moduleStatus, routeName }) => (
	<View style={css.dependency_output}>
		<Hyperlink
			linkStyle={css.hyperlink}
			linkText={url => url === moduleLink ? moduleName : url} // eslint-disable-line
			onPress={url => Linking.openURL(moduleLink)}
		>
			<View style={css.do_row}>
				<Text style={css.do_left}>Module:</Text>
				<Text style={[css.do_right, css.do_module_name]}>{moduleLink}</Text>
			</View>
		</Hyperlink>
		<Hyperlink
			linkStyle={css.hyperlink}
			linkText={url => url === moduleVersionLink ? moduleVersion : url} // eslint-disable-line
			onPress={url => Linking.openURL(moduleVersionLink)}
		>
			<View style={css.do_row}>
				<Text style={css.do_left}>Version:</Text>
				<Text style={[css.do_right, css.do_test]}>{moduleVersionLink}</Text>
			</View>
		</Hyperlink>
		<View style={css.do_row}>
			<Text style={css.do_left}>Status:</Text>
			<Text style={[css.do_right, (moduleStatus === 'PASS') ? css.do_pass : css.do_fail]}>{moduleStatus}</Text>
		</View>
		<View>
			<Button
				onPress={() => NavigationService.navigate(routeName)}
				title="Test now"
				color="#841584"
			/>
		</View>
	</View>
)

const css = StyleSheet.create({
	scrollview_container: { borderColor: '#d6d7da', borderWidth: 1 },
	testbed: { fontSize: 26, fontFamily: 'Courier', textAlign: 'center', marginBottom: 10 },
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FCFCFC', margin: 10 },
	do_row: { flexDirection: 'row', alignItems: 'flex-start' },
	do_left: { flex: 1, fontWeight: 'bold', fontSize: 13, padding: 5, textAlign: 'right' },
	do_right: { flex: 4, padding: 5, fontSize: 13, fontFamily: 'Courier', color: '#666', paddingVertical: 7 },
	do_pass: { color: 'green' },
	do_fail: { color: 'red' },
	hyperlink: { color: '#0d48a6', textDecorationLine: 'underline' },
})
export default DependencyOutput