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
						style={css.navBar}
						navigationStyles={Navigator.NavigationBar.StylesIOS}
						routeMapper={{
							LeftButton: function(route, navigator, index, navState) {
								if (route.id === 'Home') {
									return null;
								} else {
									return (
										<View>
											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => navigator.pop()}>
												<Text style={css.navBarLeftButton}>
													&nbsp;&lt; Back
												</Text>
											</TouchableHighlight>
										</View>
									);
								}
							},

							Title: function(route, navigator, index, navState) {
								return (
									<View>
										<Text style={css.navBarTitle}>
											{route.title}
										</Text>
									</View>
								);
							},

							RightButton: function(route, navigator, index, navState) {
								if (route.id !== 'Home') {
									return null;
								}

								// for the home view, show the preferences button
								return (
									<View style={[css.navBarLeftButtonContainer, { paddingBottom: 10 }]}>
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
											<Icon style={css.navBarLeftButton} name="cog" />
										</TouchableHighlight>
									</View>
								);
							}
						}}
					/>
				}
			/>
		);
	}
}
