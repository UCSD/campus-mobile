'use strict';

import React from 'react';
import {
	View,
	WebView
} from 'react-native';


var css = require('../styles/css');
var logger = require('../util/logger');


var WebWrapper = React.createClass({

	getInitialState: function() {
		return {
			scriptInject: 'var elem = document.querySelector("#form_container h1");' + 
						  'elem.parentNode.removeChild(elem);'
		}
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<WebView
					injectedJavaScript={ this.state.scriptInject }
					ref={'webview'}
					style={css.webview_container}
					startInLoadingState={true}
					source={{uri: this.props.route.webViewURL }}  />
			</View>
		);
	},
	
});

module.exports = WebWrapper;