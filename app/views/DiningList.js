'use strict';

import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	ScrollView,
	Image,
	ListView,
	ActivityIndicator,
} from 'react-native';

var css = require('../styles/css');
var logger = require('../util/logger');
var general = require('../util/general');
var DiningDetail = require('./DiningDetail');

var DiningList = React.createClass({

	getInitialState: function() {

		var breakfastItems = [],
			lunchItems = [],
			dinnerItems = [];

		var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		var marketData = this.props.route.marketData;

		for (var i = 0; marketData.menuItems.length > i; i++) {
			var menuItem = marketData.menuItems[i];
			var menuItemTags = menuItem.tags;

			if (menuItemTags.indexOf('Breakfast') >= 0) {
				breakfastItems.push(menuItem);
			}
			if (menuItemTags.indexOf('Lunch') >= 0) {
				lunchItems.push(menuItem);
			}
			if (menuItemTags.indexOf('Dinner') >= 0) {
				dinnerItems.push(menuItem);
			}
		}

		return {
			marketData: this.props.route.marketData,
			marketDataFull: ds.cloneWithRows( this.props.route.marketData.menuItems ),

			menuItemsActive: null,
			menuItemsBreakfast: ds.cloneWithRows( breakfastItems ),
			menuItemsLunch: ds.cloneWithRows( lunchItems ),
			menuItemsDinner: ds.cloneWithRows( dinnerItems ),
			
			mealFilter: null,
		};
	},

	componentWillMount: function() {

		// Default to Breakfast, Lunch, Dinner based on time of day
		// TODO: Rework based on open hours once the feed is improved
		var currentHour = general.getTimestamp('H');
		var currentMinute = general.getTimestamp('M');
		
		if ( (currentHour < 10) || (currentHour === 10 && currentMinute <= 30) ) {
			// Breakfast <= 10:30 AM
			this.setMealFilter('breakfast');
		} else if (currentHour <= 16) {
			// Lunch 10:31 AM - 4:59 PM
			this.setMealFilter('lunch');
		} else {
			// Dinner 5:00pm - 12:00AM
			this.setMealFilter('dinner');
		}

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

						{this.state.marketData.images ? (
							<ScrollView style={css.dl_market_scroller} directionalLockEnabled={false} horizontal={true}>
								{this.state.marketData.images.map(function(object, i) {
									return (<Image style={css.dl_market_scroller_image} source={{ uri: object }} />);
								})}
							</ScrollView>
						) : null }

						<View style={css.dl_market_directions}>
							<Text style={css.dl_dir_label}>Directions</Text>

							<TouchableHighlight style={css.dl_dir_traveltype_container} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { return }}>
								<View style={css.dl_dir_traveltype_container}>
									<Image style={css.dl_dir_icon} source={ require('../assets/img/icon_walk.png')} />
									<Text style={css.dl_dir_eta}>25 mins</Text>
								</View>
							</TouchableHighlight>

							<TouchableHighlight style={css.dl_dir_traveltype_container} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { return }}>
								<View style={css.dl_dir_traveltype_container}>
									<Image style={css.dl_dir_icon} source={ require('../assets/img/icon_bike.png')} />
									<Text style={css.dl_dir_eta}>15 mins</Text>
								</View>
							</TouchableHighlight>
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
							{this.state.mealFilter === 'breakfast' ? (
								<TouchableHighlight style={css.dl_meal_button} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { this.setMealFilter('breakfast')}}>
									<View style={css.dl_meal_button}>
										<View style={css.dl_mealtype_circle_active}></View>
										<Text style={css.dl_mealtype_label_active}>Breakfast</Text>
									</View>
								</TouchableHighlight>
							) : (
								<TouchableHighlight style={css.dl_meal_button} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { this.setMealFilter('breakfast')}}>
									<View style={css.dl_meal_button}>
										<View style={css.dl_mealtype_circle}></View>
										<Text style={css.dl_mealtype_label}>Breakfast</Text>
									</View>
								</TouchableHighlight>
							)}
							{this.state.mealFilter === 'lunch' ? (
								<TouchableHighlight style={css.dl_meal_button} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { this.setMealFilter('lunch')}}>
									<View style={css.dl_meal_button}>
										<View style={css.dl_mealtype_circle_active}></View>
										<Text style={css.dl_mealtype_label_active}>Lunch</Text>
									</View>
								</TouchableHighlight>
							) : (
								<TouchableHighlight style={css.dl_meal_button} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { this.setMealFilter('lunch')}}>
									<View style={css.dl_meal_button}>
										<View style={css.dl_mealtype_circle}></View>
										<Text style={css.dl_mealtype_label}>Lunch</Text>
									</View>
								</TouchableHighlight>
							)}
							{this.state.mealFilter === 'dinner' ? (
								<TouchableHighlight style={css.dl_meal_button} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { this.setMealFilter('dinner')}}>
									<View style={css.dl_meal_button}>
										<View style={css.dl_mealtype_circle_active}></View>
										<Text style={css.dl_mealtype_label_active}>Dinner</Text>
									</View>
								</TouchableHighlight>
							) : (
								<TouchableHighlight style={css.dl_meal_button} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { this.setMealFilter('dinner')}}>
									<View style={css.dl_meal_button}>
										<View style={css.dl_mealtype_circle}></View>
										<Text style={css.dl_mealtype_label}>Dinner</Text>
									</View>
								</TouchableHighlight>
							)}
						</View>

						{this.state.menuItemsActive ? (
							<View style={css.dl_market_menu}>
								<ListView dataSource={this.state.menuItemsActive} renderRow={ (data) => {
									return (
										<TouchableHighlight style={css.dl_market_menu_row} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningDetail(data) }>
											<Text style={css.dl_menu_item_name}>{data.name}<Text style={css.dl_menu_item_price}> (${data.price})</Text></Text>
										</TouchableHighlight>
									)
								}} />
							</View>
						) : (
							<View style={[css.center, css.shuttle_card_loader]}>
								<ActivityIndicator style={css.shuttle_card_aa} size="large" />
							</View>
						)}

					</View>
				</ScrollView>
			</View>
		);
	},

	setMealFilter: function(meal) {
		var dsClone;
		if (meal === 'breakfast') {
			dsClone = this.state.menuItemsBreakfast;
		} else if (meal === 'lunch') {
			dsClone = this.state.menuItemsLunch;
		} else {
			dsClone = this.state.menuItemsDinner;
		}
		this.setState({
			mealFilter: meal,
			menuItemsActive: dsClone,
		});
	},

	updateDiningFilters: function(filter) {
		logger.log('updateDiningFilters: ' + filter)

	},

	gotoDiningDetail: function(data) {
		this.props.navigator.push({ id: 'DiningDetail', name: data.name, title: data.name, menuItem: data, component: DiningDetail });
	},

	gotoDestinationDetail: function(destinationData) {
		destinationData.currentLat = this.getCurrentPosition('lat');
		destinationData.currentLon = this.getCurrentPosition('lon');

		destinationData.mkrLat = parseFloat(destinationData.mkrLat);
		destinationData.mkrLong = parseFloat(destinationData.mkrLong);

		destinationData.distLatLon = Math.sqrt(Math.pow(Math.abs(this.getCurrentPosition('lat') - destinationData.mkrLat), 2) + Math.pow(Math.abs(this.getCurrentPosition('lon') - destinationData.mkrLong), 2));
		this.props.navigator.push({ id: 'DestinationDetail', name: 'Nearby', title: 'Nearby', component: DestinationDetail, destinationData: destinationData });
	},

});

module.exports = DiningList;