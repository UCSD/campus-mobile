import React, { Component } from 'react';
import {
	View,
	WebView
} from 'react-native';

const css = require('../styles/css');

class WebWrapper extends Component {
	getInitialState() {
		const title = this.props.route.title;
		let scriptInjectStr = '';
		return {
			scriptInject: scriptInjectStr
		};
	}

	renderScene() {
		return (
			<View style={css.main_full}>
				<WebView
					injectedJavaScript={this.state.scriptInject}
					ref={(w) => { this.webview = w; }}
					style={css.webview_container}
					startInLoadingState={true}
					source={{ uri: this.props.route.webViewURL }}
				/>
			</View>
		);
	}

	render() {
		return this.renderScene();
	}
}

module.exports = WebWrapper;
