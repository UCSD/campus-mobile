/**
 * Campus Mobile Dependency Upgrade Testbed
 */
import React, { Fragment } from 'react'
import {
	SafeAreaView,
	ScrollView,
	View,
	Text,
	StatusBar,
	StyleSheet,
	Linking,
} from 'react-native'
import Hyperlink from 'react-native-hyperlink'

const dateformat = require('dateformat')
const html_entities = require('html-entities').XmlEntities
const moment = require('moment')
const node_forge = require('node-forge')

const App = () => (
	<Fragment>
		<SafeAreaView>
			<ScrollView contentInsetAdjustmentBehavior="automatic" style={css.scrollview_container}>
				<View>
					<Text style={css.testbed}>
						Campus Mobile Dependency Upgrade Testbed
					</Text>
					<TEST_dateformat />
					<TEST_react_native_hyperlink />
					<TEST_html_entities />
					<TEST_moment />
				</View>
			</ScrollView>
		</SafeAreaView>
	</Fragment>
)

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
		/>
	)
}

const TEST_react_native_hyperlink = () => (
	<DependencyOutput
		moduleName="react-native-hyperlink"
		moduleLink="https://github.com/obipawan/react-native-hyperlink"
		moduleVersion="0.0.14"
		moduleVersionLink="https://github.com/obipawan/react-native-hyperlink/releases/tag/v0.0.14"
		moduleTest="<Hyperlink ... />"
		moduleOutput="https://ucsd.edu/"
	/>
)

const TEST_html_entities = () => {
	const entities = new html_entities()
	return (
		<DependencyOutput
			moduleName="html-entities"
			moduleLink="https://github.com/mdevils/node-html-entities"
			moduleVersion="1.2.1"
			moduleVersionLink="https://github.com/mdevils/node-html-entities/releases/tag/v1.2.1"
			moduleTest="encode('<>')"
			moduleOutput={entities.encode('<>')}
		/>
	)
}

const TEST_moment = () => (
	<DependencyOutput
		moduleName="moment"
		moduleLink="https://github.com/moment/moment/"
		moduleVersion="2.24.0"
		moduleVersionLink="https://github.com/moment/moment/releases/tag/2.24.0"
		moduleTest="moment().format('LLLL')"
		moduleOutput={moment().format('LLLL')}
	/>
)

const TEST_node_forge = () => (
	<DependencyOutput
		moduleName="node-forge"
		moduleLink="https://github.com/digitalbazaar/forge"
		moduleVersion="0.8.5"
		moduleVersionLink="https://github.com/digitalbazaar/forge/releases/tag/0.8.5"
		moduleTest="moment().format('LLLL')"
		moduleOutput={moment().format('LLLL')}
	/>
)

const DependencyOutput = ({ moduleName, moduleLink, moduleVersion, moduleVersionLink, moduleTest, moduleOutput }) => (
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
	</View>
)

const ucsdPublicKey = '-----BEGIN PUBLIC KEY-----\n'
	+ 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n'
	+ 'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n'
	+ 'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n'
	+ 'CaCUGqS6FN1nNKARGwIDAQAB\n'
	+ '-----END PUBLIC KEY-----'

const css = StyleSheet.create({
	scrollview_container: { margin: 10, borderColor: '#d6d7da', borderWidth: 1 },
	testbed: { fontSize: 22, fontFamily: 'Courier' },
	dependency_output: { borderWidth: 1, borderColor: '#d6d7da', borderRadius: 5, backgroundColor: '#FAFAFA', margin: 10 },
	do_row: { flexDirection: 'row', alignItems: 'flex-start' },
	do_left: { flex: 1, fontWeight: 'bold', fontSize: 13, padding: 5, textAlign: 'right' },
	do_right: { flex: 4, padding: 5, fontSize: 13, fontFamily: 'Courier', color: '#666', paddingVertical: 7 },
	hyperlink: { color: '#0d48a6', textDecorationLine: 'underline' },
})

export default App
