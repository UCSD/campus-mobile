'use strict';

import React from 'react';
import {
	View,
	WebView,
	Text
} from 'react-native';

var css = require('../styles/css');
var logger = require('../util/logger');
/*
<div jstcache="1352" class="ml-snackbar-link-unsupported-error ml-snackbar-without-action" style="
	display: none;
"> <span class="ml-snackbar-text">This link is not supported in the mobile web version of Google Maps.</span> </div>

<span class="ml-directions-travel-mode-time ml-directions-travel-mode-car">1 min</span>
*/

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

		logger.log('url2: ' + this.state.google_maps_url);

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