import React from 'react';
import {
	TouchableHighlight,
  Image,
} from 'react-native';

const WebWrapper = require('../WebWrapper');
const css = require('../../styles/css');

// Card for displaying a large banner on the top of the screen
export default class BannerView extends React.Component {
	gotoWebView = () => {
    // launch website
		this.props.navigator.push({ id: 'WebWrapper', component: WebWrapper, title: this.props.site.title, webViewURL: this.props.site.url });
	}
	render() {
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={this.gotoWebView}>
				<Image style={[css.card_plain, css.card_special_events]} source={this.props.bannerImage} />
			</TouchableHighlight>
    );
	}
}
