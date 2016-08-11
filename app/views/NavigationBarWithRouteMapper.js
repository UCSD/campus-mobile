import React from 'react';
import {
	Navigator,
	Text,
	TouchableHighlight,
} from 'react-native';

var css = require('../styles/css');

export default class NavigationBarWithRouteMapper extends React.Component {
	constructor(props) {
		super(props);
	}

	render() {
		return(
			<Navigator
				initialRoute={this.props.route}
				renderScene={this.props.renderScene}
				navigator={this.props.navigator}
				navigationBar={
					<Navigator.NavigationBar 
					style={css.navBar} 
					routeMapper={{
						LeftButton: function(route, navigator, index, navState) {
							if(route.id === 'Home') {
								return null;
							}
							return (
								<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => navigator.parentNavigator.pop()}>
									<Text style={css.navBarLeftButton}>
										&lt; Back
									</Text>
								</TouchableHighlight>
							);
						},

						RightButton: function(route, navigator, index, navState) {
							return null;
						},

						Title: function(route, navigator, index, navState) {
							return (
								<Text style={css.navBarTitle}>
									{route.title}
								</Text>
							);
						}}
					} />
			}/>
			
		);
	}
};
