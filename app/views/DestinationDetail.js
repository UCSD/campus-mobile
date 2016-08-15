'use strict';

import React from 'react';
import {
	View,
	WebView,
	Text
} from 'react-native';

var css = require('../styles/css');
var logger = require('../util/logger');

var DestionationDetail2 = React.createClass({

	getInitialState: function() {
		return {
			google_maps_url: 	'https://www.google.com/maps/dir/' + 
							  	this.props.route.destinationData.currentLat + ',' + this.props.route.destinationData.currentLon + '/' +
							  	this.props.route.destinationData.mkrLat + ',' + this.props.route.destinationData.mkrLong + '/@' +
							  	this.props.route.destinationData.currentLat + ',' + this.props.route.destinationData.currentLon + ',18z/data=!4m2!4m1!3e2',

			scriptInject: 		'document.querySelector(".ml-snackbar-link-unsupported-error.ml-snackbar-without-action").setAttribute("style", "display:none!important");',
		}
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function(route, navigator) {
		return (
			<View style={[css.main_container, css.offwhitebg]}>
				<WebView
					injectedJavaScript={ this.state.scriptInject }
					ref={'webview'}
					style={css.destination_detail_map}
					startInLoadingState={true}
					source={{uri: this.state.google_maps_url }}  />
			</View>
		);
	},
	
});

module.exports = DestionationDetail2;