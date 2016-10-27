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
		var title = this.props.route.title;

		var scriptInjectStr = '';

		if (title === 'Feedback') {
			scriptInjectStr =	'var elem = document.querySelector("#form_container h1"); elem.parentNode.removeChild(elem);';
			scriptInjectStr += 	'document.documentElement.style.background = "white";';
			scriptInjectStr += 	'document.querySelector("#form_container").style.boxShadow=null;'
		} else if (title === 'Welcome Week') {
			scriptInjectStr =	'document.querySelector("#header").style.display = "none";'+
								'document.querySelector(".center.content-padded").style.display = "none";'+
								'document.querySelector("#ww-button-ucsd").style.display = "none";'+
								'document.querySelector("#footer").style.display = "none";';
		}

		return {
			scriptInject: scriptInjectStr
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
					source={{uri: this.props.route.webViewURL }} />
			</View>
		);
	},
	
});

module.exports = WebWrapper;