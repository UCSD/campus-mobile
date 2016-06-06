'use strict';

import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView
} from 'react-native';

var css = require('../styles/css');
var logger = require('../util/logger');

var DiningDetail = React.createClass({

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>

					<Image style={css.dining_card_detail_img} source={ require('image!DiningDetail-PH')} />

				</ScrollView>
			</View>
		);
	},
});

module.exports = DiningDetail;