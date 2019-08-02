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
		moduleName: 'bugsnag-react-native',
		moduleLink: 'https://github.com/bugsnag/bugsnag-react-native',
		moduleVersion: '2.22.4',
		moduleVersionLink: 'https://github.com/bugsnag/bugsnag-react-native/releases/tag/v2.22.4',
		moduleStatus: 'TBD',
		routeName: 'bugsnag_react_native'
	},
	{
		moduleName: 'react-native-firebase',
		moduleLink: 'https://github.com/invertase/react-native-firebase',
		moduleVersion: '5.5.6',
		moduleVersionLink: 'https://github.com/invertase/react-native-firebase/releases/tag/v5.5.6',
		moduleStatus: 'PASS',
		routeName: 'react_native_firebase'
	},
	{
		moduleName: 'react-native-permissions',
		moduleLink: 'https://github.com/react-native-community/react-native-permissions',
		moduleVersion: '1.2.0',
		moduleVersionLink: 'https://github.com/react-native-community/react-native-permissions/releases/tag/1.2.0',
		moduleStatus: 'PASS',
		routeName: 'react_native_permissions'
	},
	{
		moduleName: 'react-native-simple-toast',
		moduleLink: 'https://github.com/vonovak/react-native-simple-toast',
		moduleVersion: '0.1.1',
		moduleVersionLink: 'https://github.com/vonovak/react-native-simple-toast/releases/tag/v0.1.1',
		moduleStatus: 'PASS',
		routeName: 'react_native_simple_toast'
	},
	{
		moduleName: 'redux-saga',
		moduleLink: 'https://github.com/redux-saga/redux-saga',
		moduleVersion: '1.0.0',
		moduleVersionLink: 'https://github.com/redux-saga/redux-saga/releases/tag/v1.0.0',
		moduleStatus: 'PASS',
		routeName: 'redux_saga'
	},
	{
		moduleName: 'redux-persist-transform-filter',
		moduleLink: 'https://github.com/edy/redux-persist-transform-filter',
		moduleVersion: '0.0.15',
		moduleVersionLink: 'https://github.com/edy/redux-persist-transform-filter/releases/tag/0.0.15',
		moduleStatus: 'PASS',
		routeName: 'redux_persist_transform_filter'
	},
	{
		moduleName: 'react-native-community/async-storage',
		moduleLink: 'https://github.com/react-native-community/async-storage',
		moduleVersion: '1.5.1',
		moduleVersionLink: 'https://github.com/react-native-community/async-storage/releases/tag/v1.5.1',
		moduleStatus: 'PASS',
		routeName: 'react_native_async_storage'
	},
	{
		moduleName: 'redux-persist',
		moduleLink: 'https://github.com/rt2zz/redux-persist',
		moduleVersion: '5.10.0',
		moduleVersionLink: 'https://github.com/rt2zz/redux-persist/releases/tag/v5.10.0',
		moduleStatus: 'PASS',
		routeName: 'redux_persist'
	},
	{
		moduleName: 'redux-logger',
		moduleLink: 'https://github.com/LogRocket/redux-logger',
		moduleVersion: '3.0.6',
		moduleVersionLink: 'https://github.com/LogRocket/redux-logger/releases/tag/3.0.6',
		moduleStatus: 'PASS',
		routeName: 'redux_logger'
	},
	{
		moduleName: 'react-redux',
		moduleLink: 'https://www.github.com/reduxjs/redux',
		moduleVersion: '4.0.4',
		moduleVersionLink: 'https://github.com/reduxjs/redux/releases/tag/v4.0.4',
		moduleStatus: 'PASS',
		routeName: 'react_redux'
	},
	{
		moduleName: 'react-native-vector-icons',
		moduleLink: 'https://github.com/oblador/react-native-vector-icons',
		moduleVersion: '6.6.0',
		moduleVersionLink: 'https://github.com/oblador/react-native-vector-icons/releases/tag/v6.6.0',
		moduleStatus: 'PASS',
		routeName: 'react_native_vector_icons'
	},
	{
		moduleName: 'react-native-system-setting',
		moduleLink: 'https://github.com/c19354837/react-native-system-setting',
		moduleVersion: '1.7.2',
		moduleVersionLink: 'https://github.com/c19354837/react-native-system-setting/releases/tag/V1.7.2',
		moduleStatus: 'PASS',
		routeName: 'react_native_system_setting'
	},
	{
		moduleName: 'react-native-restart',
		moduleLink: 'https://github.com/avishayil/react-native-restart',
		moduleVersion: '0.0.12',
		moduleVersionLink: 'https://github.com/avishayil/react-native-restart/releases/tag/v0.0.12',
		moduleStatus: 'PASS',
		routeName: 'react_native_restart'
	},
	{
		moduleName: 'react-native-maps',
		moduleLink: 'https://github.com/react-native-community/react-native-maps',
		moduleVersion: '0.25.0',
		moduleVersionLink: 'https://github.com/react-native-community/react-native-maps/releases/tag/v0.25.0',
		moduleStatus: 'TBD',
		routeName: 'react_native_maps'
	},
	{
		moduleName: 'react-native-keychain',
		moduleLink: 'https://github.com/oblador/react-native-keychain',
		moduleVersion: '3.1.3',
		moduleVersionLink: 'https://github.com/oblador/react-native-keychain/releases/tag/v3.1.3',
		moduleStatus: 'PASS',
		routeName: 'react_native_keychain'
	},
	{
		moduleName: 'react-native-exit-app',
		moduleLink: 'https://github.com/wumke/react-native-exit-app',
		moduleVersion: '1.0.0',
		moduleVersionLink: 'https://github.com/wumke/react-native-exit-app',
		moduleStatus: 'TBD',
		routeName: 'react_native_exit_app'
	},
	{
		moduleName: 'react-native-exception-handler',
		moduleLink: 'https://github.com/master-atul/react-native-exception-handler',
		moduleVersion: '2.10.8',
		moduleVersionLink: 'https://github.com/master-atul/react-native-exception-handler/releases/tag/2.10.8',
		moduleStatus: 'PASS',
		routeName: 'react_native_exception_handler'

	},
	{
		moduleName: 'react-native-device-info',
		moduleLink: 'https://github.com/react-native-community/react-native-device-info',
		moduleVersion: '2.2.2',
		moduleVersionLink: 'https://github.com/react-native-community/react-native-device-info/releases/tag/v2.2.2',
		moduleStatus: 'PASS',
		routeName: 'react_native_device_info'
	},
	{
		moduleName: 'node-forge',
		moduleLink: 'https://github.com/digitalbazaar/forge',
		moduleVersion: '0.8.5',
		moduleVersionLink: 'https://github.com/digitalbazaar/forge/releases/tag/0.8.5',
		moduleStatus: 'PASS',
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
	},
	{
		moduleName: 'react-native-datepicker',
		moduleLink: 'https://github.com/xgfe/react-native-datepicker',
		moduleVersion: '1.7.0',
		moduleVersionLink: 'https://github.com/xgfe/react-native-datepicker/releases/tag/v1.7.0',
		moduleStatus: 'PASS',
		routeName: 'react_native_datepicker'
	},
	{
		moduleName: 'react-native-popup-menu',
		moduleLink: 'https://github.com/instea/react-native-popup-menu',
		moduleVersion: '0.15.5',
		moduleVersionLink: 'https://github.com/instea/react-native-popup-menu/releases/tag/0.15.5',
		moduleStatus: 'PASS',
		routeName: 'react_native_popup_menu'
	},
	{
		moduleName: 'react-native-sortable-list',
		moduleLink: 'https://github.com/gitim/react-native-sortable-list',
		moduleVersion: '0.0.23',
		moduleVersionLink: 'https://github.com/gitim/react-native-sortable-list/releases/tag/v0.0.23',
		moduleStatus: 'PASS',
		routeName: 'react_native_sortable_list'
	},
	{
		moduleName: 'react-navigation-header-buttons',
		moduleLink: 'https://github.com/vonovak/react-navigation-header-buttons',
		moduleVersion: '3.0.1',
		moduleVersionLink: 'https://github.com/vonovak/react-navigation-header-buttons/releases/tag/v3.0.1',
		moduleStatus: 'PASS',
		routeName: 'react_navigation_header_buttons'
	},
	{
		moduleName: 'react-native-circle-checkbox',
		moduleLink: 'https://github.com/paramoshkinandrew/ReactNativeCircleCheckbox',
		moduleVersion: '0.1.6',
		moduleVersionLink: 'https://github.com/paramoshkinandrew/ReactNativeCircleCheckbox/releases/tag/0.1.6',
		moduleStatus: 'PASS',
		routeName: 'react_native_circle_checkbox'
	}
]

const css = StyleSheet.create({
	flatlist_style: { borderColor: '#d6d7da', borderWidth: 1 , marginTop: 32, marginBottom: 32 },
	flatlist_container: { flexGrow: 1, justifyContent: 'center' },
	module_name_text: { textAlign: 'center', fontSize: 20 },
})
