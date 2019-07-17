/**
 * Campus Mobile Dependency Upgrade Testbed
 */
/* eslint react/jsx-pascal-case: 0 */
import React, { Fragment } from 'react'
import { ScrollView, View, Text, StyleSheet, Linking, StatusBar } from 'react-native'
import Barcode from 'react-native-barcode-builder'

import DependencyOutput from './test_components/reusable/DependencyOutput'
import TestList from './test_components/reusable/TestList'
import Router from './test_components/react-navigation/Router'


const App = () => (
	<Router />
)

const TEST_react_native_barcode_builder = () => (
	<DependencyOutput
		moduleName="react-native-barcode-builder"
		moduleLink="https://github.com/wonsikin/react-native-barcode-builder"
		moduleVersion="1.0.5"
		moduleVersionLink="https://github.com/wonsikin/react-native-barcode-builder/releases/tag/v1.0.5"
		moduleTest="<Barcode />"
		moduleOutput="N/A"
		moduleStatus="FAIL"
	/>
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

export default App
