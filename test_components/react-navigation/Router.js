import React from 'react'
import {
	createStackNavigator,
	createAppContainer
} from 'react-navigation'
// import { MenuProvider } from 'react-native-popup-menu'

import NavigationService from './NavigationService'
import TestList from '../reusable/TestList'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

import node_forge_test from '../node-forge/node_forge_test'
import dateformat_test from '../dateformat/dateformat_test'
import react_native_hyperlink_test from '../react-native-hyperlink/react_native_hyperlink_test'
import moment_test from '../moment/moment_test'
import html_entities_test from '../html-entities/html_entities_test'
import react_native_animatable_test from '../react-native-animatable/react_native_animatable_test'
import animated_circular_progress_test from '../animated-circular-progress/animated_circular_progress_test'
import react_native_svg_test from '../react-native-svg/react_native_svg_test'
import react_native_barcode_builder_test from '../react-native-barcode-builder/react_native_barcode_builder_test'
import react_native_datepicker_test from '../react-native-datepicker/react_native_datepicker_test'
import react_native_popup_menu_test from '../react-native-popup-menu/react_native_popup_menu_test'

let MainStack = createStackNavigator(
	{
		MainPage: {
			screen: TestList,
			navigationOptions: { header: null }
		},
		node_forge: {
			screen: node_forge_test,
			navigationOptions: { title: 'node-forge-test' }
		},
		dateformat: {
			screen: dateformat_test,
			navigationOptions: { title: 'dateformat-test' }
		},
		react_native_hyperlink: {
			screen: react_native_hyperlink_test,
			navigationOptions: { title: 'react-native-hyperlink-test' }
		},
		moment: {
			screen: moment_test,
			navigationOptions: { title: 'moment-test' }
		},
		html_entities: {
			screen: html_entities_test,
			navigationOptions: { title: 'html-entities-test' }
		},
		react_native_animatable: {
			screen: react_native_animatable_test,
			navigationOptions: { title: 'react-native-animatable-test' }
		},
		animated_circular_progress: {
			screen: animated_circular_progress_test,
			navigationOptions: { title: 'animated-circular-progress-test' }
		},
		react_native_svg: {
			screen: react_native_svg_test,
			navigationOptions: { title: 'react-native-svg-test' }
		},
		react_native_barcode_builder: {
			screen: react_native_barcode_builder_test,
			navigationOptions: { title: 'react-native-barcode-builder' }
		},
		react_native_datepicker: {
			screen: react_native_datepicker_test,
			navigationOptions: { title: 'react-native-datepicker' }
		},
		react_native_popup_menu: {
			screen: react_native_popup_menu_test,
			navigationOptions: { title: 'react-native-popup-menu' }
		}
	},
	{
		initialRouteName: 'MainPage',
		defaultNavigationOptions: {
			headerStyle: css.nav,
			headerTitleStyle: css.navTitle,
			headerTintColor: COLOR.WHITE,
		},
		headerLayoutPreset: 'center',
		cardStyle: { backgroundColor: COLOR.BG_GRAY }
	},
)

MainStack = createAppContainer(MainStack)

const Router = () => (
	<MainStack ref={navigatorRef => NavigationService.setTopLevelNavigator(navigatorRef)} />
)

export default Router
