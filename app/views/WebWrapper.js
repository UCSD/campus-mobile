import React from 'react';
import {
	View,
	WebView
} from 'react-native';

const css = require('../styles/css');

const WebWrapper = React.createClass({

	getInitialState() {
		const title = this.props.route.title;

		let scriptInjectStr = '';

		if (title === 'Feedback') {
			scriptInjectStr =	'var elem = document.querySelector("#form_container h1"); elem.parentNode.removeChild(elem);';
			scriptInjectStr += 	'document.documentElement.style.background = "white";';
			scriptInjectStr += 	'document.querySelector("#form_container").style.boxShadow=null;';
		} else if (title === 'Welcome Week') {
			scriptInjectStr =	'document.querySelector("#header").style.display = "none";' +
								'document.querySelector(".center.content-padded").style.display = "none";' +
								'document.querySelector("#ww-button-ucsd").style.display = "none";' +
								'document.querySelector("#footer").style.display = "none";';
		}

		return {
			scriptInject: scriptInjectStr
		};
	},

	renderScene() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<WebView
					injectedJavaScript={this.state.scriptInject}
					ref={(w) => { this.webview = w; }}
					style={css.webview_container}
					startInLoadingState={true}
					source={{ uri: this.props.route.webViewURL }}
				/>
			</View>
		);
	},

	render() {
		return this.renderScene();
	},

});

module.exports = WebWrapper;
