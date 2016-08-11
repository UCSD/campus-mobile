import React from 'react';
import {
	Navigator,
	Text,
	TouchableHighlight,
	View,
} from 'react-native';

var css = require('../styles/css');

export default class NavigationBarWithRouteMapper extends React.Component {
	constructor(props) {
		super(props);
	}

	render() {
		return(
			<Navigator
				ref="navRef"
				initialRoute={this.props.route}
				renderScene={this.props.renderScene}
				navigationBar={
					<Navigator.NavigationBar 
					style={css.navBar} 
					routeMapper={{
						LeftButton: function(route, navigator, index, navState) {
							if(route.id === 'Home') {
								return null;
							}
							return (
								<View>
								<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => navigator.pop()}>
									<Text style={css.navBarLeftButton}>
										&lt; Back
									</Text>
								</TouchableHighlight>
								</View>
							);
						},

						RightButton: function(route, navigator, index, navState) {
							return null;
						},

						Title: function(route, navigator, index, navState) {
							return (
								<View>
								<Text style={css.navBarTitle}>
									{route.title}
								</Text>
								</View>
							);
						}}
					} />
			}/>
			
		);
	}
};
