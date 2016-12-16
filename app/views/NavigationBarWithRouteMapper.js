import React from 'react';
import {
	Navigator,
	Text,
	TouchableHighlight,
	View,
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';
import PreferencesView from './preferences/PreferencesView';

const css = require('../styles/css');

export default class NavigationBarWithRouteMapper extends React.Component {
	render() {
		return (
			<Navigator
				ref="navRef"
				initialRoute={this.props.route}
				renderScene={this.props.renderScene}
				navigationBar={
					<Navigator.NavigationBar
						style={css.navigator}
						navigationStyles={Navigator.NavigationBar.StylesIOS}
						routeMapper={{
							LeftButton: function(route, navigator, index, navState) {
								if (route.id === 'Home') {
									return null;
								} else {
									return (
										<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => navigator.pop()}>
											<Icon style={css.navigatorLeft} name='angle-left' />
										</TouchableHighlight>
									);
								}
							},

							Title: function(route, navigator, index, navState) {
								return (
									<Text style={css.navigatorTitle}>{route.title}</Text>
								);
							},

							RightButton: function(route, navigator, index, navState) {
								if (route.id !== 'Home') {
									return null;
								} else {
									// for the home view, show the preferences button
									return (
										<TouchableHighlight
											underlayColor={'rgba(200,200,200,.1)'}
											onPress={() => {
												navigator.push({
													id: 'PreferencesView',
													component: PreferencesView,
													title: 'Preferences'
												});
											}}
										>
											<Icon style={css.navigatorRight} name='cog' />
										</TouchableHighlight>
									);
								}
							}
						}}
					/>
				}
			/>
		);
	}
}
