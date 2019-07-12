/**
 * Campus Mobile Dependency Upgrade Testbed
 */
/* eslint react/jsx-pascal-case: 0 */
import React, { Fragment } from 'react'
import { ScrollView, View, Text, StyleSheet, Linking, StatusBar } from 'react-native'
import Hyperlink from 'react-native-hyperlink'
import * as Animatable from 'react-native-animatable'
import Barcode from 'react-native-barcode-builder'

const dateformat = require('dateformat')
const entities = require('html-entities').XmlEntities
const moment = require('moment')
const forge = require('node-forge')

const App = () => (
	<ScrollView contentInsetAdjustmentBehavior="automatic" style={css.scrollview_container}>
		<View>
			<Text style={css.testbed}>Campus Mobile Dependency Testbed</Text>

			{/* FAIL */}
			<TEST_react_native_barcode_builder />

			{/* TBD / INCOMPLETE */}
			<TEST_react_native_circular_progress />
			<TEST_node_forge />

			{/* PASS */}
			<TEST_dateformat />
			<TEST_react_native_hyperlink />
			<TEST_html_entities />
			<TEST_moment />
			<TEST_react_native_animatable />
		</View>
	</ScrollView>
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

const TEST_react_native_circular_progress = () => (
	<DependencyOutput
		moduleName="react-native-circular-progress"
		moduleLink="https://github.com/bartgryszko/react-native-circular-progress"
		moduleVersion="1.1.0"
		moduleVersionLink="https://github.com/bartgryszko/react-native-circular-progress"
		moduleTest="<AnimatedCircularProgress />"
		moduleOutput="N/A"
		moduleStatus="TBD"
	/>
)

const TEST_node_forge = () => {
	const { pki } = forge
	const ucsdPublicKey = '-----BEGIN PUBLIC KEY-----\n'
		+ 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n'
		+ 'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n'
		+ 'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n'
		+ 'CaCUGqS6FN1nNKARGwIDAQAB\n'
		+ '-----END PUBLIC KEY-----'

	const pk = pki.publicKeyFromPem(ucsdPublicKey)
	return (
		<DependencyOutput
			moduleName="node-forge"
			moduleLink="https://github.com/digitalbazaar/forge"
			moduleVersion="0.8.5"
			moduleVersionLink="https://github.com/digitalbazaar/forge/releases/tag/0.8.5"
			moduleTest="pk.encrypt('test', 'RSA-OAEP')"
			moduleOutput={pk.encrypt('test', 'RSA-OAEP')}
			moduleStatus="TBD"
		/>
	)
}

const TEST_dateformat = () => {
	const now = new Date()
	return (
		<DependencyOutput
			moduleName="dateformat"
			moduleLink="https://github.com/felixge/node-dateformat"
			moduleVersion="3.0.0"
			moduleVersionLink="https://github.com/felixge/node-dateformat/releases/tag/3.0.0"
			moduleTest="dateformat(now)"
			moduleOutput={dateformat(now)}
			moduleStatus="PASS"
		/>
	)
}

const TEST_react_native_hyperlink = () => (
	<DependencyOutput
		moduleName="react-native-hyperlink"
		moduleLink="https://github.com/obipawan/react-native-hyperlink"
		moduleVersion="0.0.14"
		moduleVersionLink="https://github.com/obipawan/react-native-hyperlink/releases/tag/v0.0.14"
		moduleTest="https://ucsd.edu/"
		moduleOutput="https://ucsd.edu/"
		moduleStatus="PASS"
	/>
)

const TEST_html_entities = () => (
	<DependencyOutput
		moduleName="html-entities"
		moduleLink="https://github.com/mdevils/node-html-entities"
		moduleVersion="1.2.1"
		moduleVersionLink="https://github.com/mdevils/node-html-entities/releases/tag/v1.2.1"
		moduleTest="entities.encode('<>')"
		moduleOutput={entities.encode('<>')}
		moduleStatus="PASS"
	/>
)

const TEST_moment = () => (
	<DependencyOutput
		moduleName="moment"
		moduleLink="https://github.com/moment/moment/"
		moduleVersion="2.24.0"
		moduleVersionLink="https://github.com/moment/moment/releases/tag/2.24.0"
		moduleTest="moment.format('LLLL')"
		moduleOutput={moment().format('LLLL')}
		moduleStatus="PASS"
	/>
)

const TEST_react_native_animatable = () => (
	<DependencyOutput
		moduleName="react-native-animatable"
		moduleLink="https://github.com/oblador/react-native-animatable"
		moduleVersion="1.3.2"
		moduleVersionLink="https://github.com/oblador/react-native-animatable/releases/tag/v1.3.2"
		moduleTest="<Animatable />"
		moduleOutput={(<Animatable.Text animation="zoomIn" duration={2000} iterationCount="infinite">Zoom in animation test</Animatable.Text>)}
		moduleStatus="PASS"
	/>
)


const DependencyOutput = ({ moduleName, moduleLink, moduleVersion, moduleVersionLink, moduleTest, moduleOutput, moduleStatus }) => (
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
			<Text style={css.do_left}>Test:</Text>
			<Text style={[css.do_right, css.do_test]}>{moduleTest}</Text>
		</View>
		<Hyperlink
			linkStyle={css.hyperlink}
			onPress={url => Linking.openURL(moduleOutput)}
		>
			<View style={css.do_row}>
				<Text style={css.do_left}>Output:</Text>
				<Text style={[css.do_right, css.do_test]}>{moduleOutput}</Text>
			</View>
		</Hyperlink>
		<View style={css.do_row}>
			<Text style={css.do_left}>Status:</Text>
			<Text style={[css.do_right, (moduleStatus === 'PASS') ? css.do_pass : css.do_fail]}>{moduleStatus}</Text>
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

export default App
