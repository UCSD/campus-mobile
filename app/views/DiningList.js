'use strict';

import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	ScrollView,
	Image,
	ListView
} from 'react-native';

var css = require('../styles/css');
var logger = require('../util/logger');
var DiningDetail = require('./DiningDetail');

var DiningList = React.createClass({

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>

					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningDetail() }>
						<Image style={css.dining_card_list_img} source={ require('image!dininglist-ph')} />
					</TouchableHighlight>

				</ScrollView>
			</View>
		);
	},

	gotoDiningDetail: function() {
		this.props.navigator.push({ id: 'DiningDetail', name: 'Cheeseburger', title: 'Cheeseburger', component: DiningDetail });
	},

});

module.exports = DiningList;