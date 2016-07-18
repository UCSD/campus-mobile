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
var general = require('../util/general');
var DiningDetail = require('./DiningDetail');

var DiningList = React.createClass({

	getInitialState: function() {

		var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		logger.log('this.props.route.marketData.menuItems')
		logger.log(this.props.route.marketData.menuItems)

		return {
			marketData: this.props.route.marketData,
			marketDataMenuSource: ds.cloneWithRows( this.props.route.marketData.menuItems ),
		};
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>
					<View style={css.dl_container}>

						<View style={css.dl_market_name}>
							<Text style={css.dl_market_name_text}>{this.state.marketData.name}</Text>
						</View>

						<ScrollView style={css.dl_market_scroller} directionalLockEnabled={false} horizontal={true}>
							{this.state.marketData.images.map(function(object, i) {
								return (<Image style={css.dl_market_scroller_image} source={{ uri: object }} />);
							})}
						</ScrollView>

						<View style={css.dl_market_directions}>
							<Text style={css.dl_dir_label}>Directions</Text>
							<View style={css.dl_dir_traveltype_container}>
								<Image style={css.dl_dir_icon} source={{ uri: 'icon_walk' }} />
								<Text style={css.dl_dir_eta}>25 mins</Text>
							</View>

							<View style={css.dl_dir_traveltype_container}>
								<Image style={css.dl_dir_icon} source={{ uri: 'icon_bike' }} />
								<Text style={css.dl_dir_eta}>15 mins</Text>
							</View>
						</View>

						<View style={css.dl_market_date}>
							<Text style={css.dl_market_date_label}>Menu for {general.getTimestamp('mmmm d, yyyy')}</Text>
						</View>

						<View style={css.dl_market_filters_foodtype}>
							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.updateDiningFilters('vegetarian') }>
								<Text style={css.dining_card_filter_button}>Vegetarian</Text>
							</TouchableHighlight>

							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.updateDiningFilters('vegan') }>
								<Text style={css.dining_card_filter_button}>Vegan</Text>
							</TouchableHighlight>

							<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.updateDiningFilters('glutenfree') }>
								<Text style={css.dining_card_filter_button}>Gluten-free</Text>
							</TouchableHighlight>
						</View>

						<View style={css.dl_market_filters_mealtype}>
							<Text style={css.dl_mealtype_label}>Breakfast</Text>
							<Text style={css.dl_mealtype_label}>Lunch</Text>
							<Text style={css.dl_mealtype_label}>Dinner</Text>
						</View>

						<View style={css.dl_market_menu}>
							<ListView dataSource={this.state.marketDataMenuSource} renderRow={ (data) => {
								return (
									<TouchableHighlight style={css.dl_market_menu_row} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningDetail(data) }>
										<Text style={css.dl_menu_item_name}>{data.name}<Text style={css.dl_menu_item_price}> (${data.price})</Text></Text>
									</TouchableHighlight>
								)}} />
						</View>

					</View>
				</ScrollView>
			</View>
		);
	},

	updateDiningFilters: function(filter) {
		logger.log('updateDiningFilters: ' + filter)

	},

	gotoDiningDetail: function(data) {
		logger.log('data:')
		logger.log(data)

		//this.props.navigator.push({ id: 'DiningDetail', name: 'test' });
		this.props.navigator.push({ id: 'DiningDetail', name: data.name, title: data.name, menuItem: data, component: DiningDetail });
	},

});

module.exports = DiningList;