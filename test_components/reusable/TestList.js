import React from 'react'
import { FlatList, StyleSheet } from 'react-native'

import DependencyOutput from './DependencyOutput'


export default class TestList extends React.Component {
	render() {
		return (
			<FlatList
				style={css.flatlist_style}
				contentContainerStyle={css.flatlist_container}
				data={data}
				renderItem={({ item }) => renderItem(item)}
				keyExtractor={item => item.moduleName}
			/>
		)
	}
}

const renderItem = item => (
	<DependencyOutput
		moduleName={item.moduleName}
		moduleLink={item.moduleLink}
		moduleVersion={item.moduleVersion}
		moduleVersionLink={item.moduleVersionLink}
		moduleStatus={item.moduleStatus}
		routeName={item.routeName}
	/>
)

const data = [
	{
		moduleName: 'node-forge',
		moduleLink: 'https://github.com/digitalbazaar/forge',
		moduleVersion: '0.8.5',
		moduleVersionLink: 'https://github.com/digitalbazaar/forge/releases/tag/0.8.5',
		component: 'import and insert component here',
		moduleStatus: 'TBD',
		routeName: 'node_forge'
	},
	{
		moduleName: 'dateformat',
		moduleLink: 'https://github.com/felixge/node-dateformat',
		moduleVersion: '3.0.0',
		moduleVersionLink: 'https://github.com/felixge/node-dateformat/releases/tag/3.0.0',
		moduleStatus: 'PASS',
		routeName: 'dateformat'
	},
	{
		moduleName: 'react-native-hyperlink',
		moduleLink: 'https://github.com/obipawan/react-native-hyperlink',
		moduleVersion: '0.0.14',
		moduleVersionLink: 'https://github.com/obipawan/react-native-hyperlink/releases/tag/v0.0.14',
		moduleStatus: 'PASS',
		routeName: 'react_native_hyperlink'
	},
	{
		moduleName: 'moment',
		moduleLink: 'https://github.com/moment/moment/',
		moduleVersion: '2.24.0',
		moduleVersionLink: 'https://github.com/moment/moment/releases/tag/2.24.0',
		moduleStatus: 'PASS',
		routeName: 'moment'
	},
	{
		moduleName: 'html-entities',
		moduleLink: 'https://github.com/mdevils/node-html-entities/',
		moduleVersion: '1.2.1',
		moduleVersionLink: 'https://github.com/mdevils/node-html-entities/releases/tag/v1.2.1',
		moduleStatus: 'PASS',
		routeName: 'html_entities'
	},
	{
		moduleName: 'react-native-animatable',
		moduleLink: 'https://github.com/oblador/react-native-animatable',
		moduleVersion: '1.3.2',
		moduleVersionLink: 'https://github.com/oblador/react-native-animatable/releases/tag/v1.3.2',
		moduleStatus: 'PASS',
		routeName: 'react_native_animatable'
	},
	{
		moduleName: 'react-native-circular-progress',
		moduleLink: 'https://github.com/bartgryszko/react-native-circular-progress',
		moduleVersion: '1.1.0',
		moduleVersionLink: 'https://github.com/bartgryszko/react-native-circular-progress',
		moduleStatus: 'PASS',
		routeName: 'animated_circular_progress'
	},
	{
		moduleName: 'react-native-svg',
		moduleLink: 'https://github.com/react-native-community/react-native-svg',
		moduleVersion: '9.5.3',
		moduleVersionLink: 'https://github.com/react-native-community/react-native-svg/releases/tag/9.5.3',
		moduleStatus: 'PASS',
		routeName: 'react_native_svg'
	},
	{
		moduleName: 'react-native-barcode-builder',
		moduleLink: 'https://github.com/wonsikin/react-native-barcode-builder',
		moduleVersion: '1.0.5',
		moduleVersionLink: 'https://github.com/wonsikin/react-native-barcode-builder/releases/tag/v1.0.5',
		moduleStatus: 'PASS',
		routeName: 'react_native_barcode_builder'
	}
]

const css = StyleSheet.create({
	flatlist_style: { borderColor: '#d6d7da', borderWidth: 1 },
	flatlist_container: { flexGrow: 1, justifyContent: 'center' },
	module_name_text: { textAlign: 'center', fontSize: 20 },
})
