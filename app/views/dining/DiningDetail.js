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
	Linking,
} from 'react-native';

var css = require('../../styles/css');
var logger = require('../../util/logger');
var general = require('../../util/general');

var DiningNutrition = require('./DiningNutrition');
var WebWrapper = require('../WebWrapper');

var DiningDetail = React.createClass({
	
	mealFilter: null,
	vegetarianFilterEnabled: false,
	veganFilterEnabled: false,
	glutenfreeFilterEnabled: false,

	getInitialState: function() {

		var breakfastItems = [],
			lunchItems = [],
			dinnerItems = [],
			ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}),
			marketData = this.props.route.data,
			menuItemsCount = 0;

		if (marketData.menuItems) {
			menuItemsCount = marketData.menuItems.length;
		}

		if (marketData.menuItems) {
			for (var i = 0; marketData.menuItems.length > i; i++) {
				var menuItem = marketData.menuItems[i];
				var menuItemTags = menuItem.tags.toLowerCase();

				if (menuItemTags.indexOf('breakfast') >= 0) {
					breakfastItems.push(menuItem);
				}
				if (menuItemTags.indexOf('lunch') >= 0) {
					lunchItems.push(menuItem);
				}
				if (menuItemTags.indexOf('dinner') >= 0) {
					dinnerItems.push(menuItem);
				}
				if (menuItemTags.indexOf('all') >= 0) {
					breakfastItems.push(menuItem);
					lunchItems.push(menuItem);
					dinnerItems.push(menuItem);
				}
			}
		}

		return {
			marketData: marketData,
			menuItemsActive: null,
			menuItemsActiveCount: null,
			menuItemsCount: menuItemsCount,
			menuItemsBreakfast: breakfastItems,
			menuItemsLunch: lunchItems,
			menuItemsDinner: dinnerItems,
		};
	},

	componentWillMount: function() {

		// Default to Breakfast, Lunch, Dinner based on time of day
		// TODO: Rework based on open hours once the feed is improved
		var currentHour = general.getTimestamp('H');
		var currentMinute = general.getTimestamp('M');

		var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
		var dsClone;

		if ( (currentHour < 10) || (currentHour == 10 && currentMinute <= 30) ) {
			// Breakfast <= 10:30 AM
			this.mealFilter = 'breakfast';
			dsClone = this.state.menuItemsBreakfast;
		} else if (currentHour <= 16) {
			// Lunch 10:31 AM - 4:59 PM
			this.mealFilter = 'lunch';
			dsClone = this.state.menuItemsLunch;
		} else {
			// Dinner 5:00pm - 12:00AM
			this.mealFilter = 'dinner';
			dsClone = this.state.menuItemsDinner;
		}

		this.setState({
			menuItemsActive: ds.cloneWithRows( dsClone ),
			menuItemsActiveCount: dsClone.length,
		});

	},

	componentDidMount: function() {
		logger.ga('View Loaded: Dining Detail: ' + this.state.marketData.name);
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
							{this.state.marketData.description ? (
								<Text style={css.dl_market_desc_text}>{this.state.marketData.description}</Text>
							) : null }
							{this.state.marketData.regularHours ? (
								<Text style={css.dl_market_desc_text}>{this.state.marketData.regularHours}</Text>
							) : null }
						</View>

						{this.state.marketData.images ? (
							<ScrollView style={css.dl_market_scroller} directionalLockEnabled={false} horizontal={true}>
								{this.state.marketData.images.map(function(object, i) {
									return (<Image key={i} style={css.dl_market_scroller_image} resizeMode={'cover'} source={{ uri: object }} />);
								})}
							</ScrollView>
						) : null }
						
						{this.state.marketData.coords.lat !== 0 && this.state.marketData.coords.lon !== 0 ? (
							<View style={css.dl_market_directions}>
								<Text style={css.dl_dir_label}>Directions</Text>

								<TouchableHighlight style={css.dl_dir_traveltype_container} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => { general.gotoNavigationApp('walk', this.state.marketData.coords.lat, this.state.marketData.coords.lon) }}>
									<View style={css.dl_dir_traveltype_container}>
										<Image style={css.dl_dir_icon} source={ require('../../assets/img/icon_walk.png')} />
										<Text style={css.dl_dir_eta}>{this.state.marketData.distanceMilesStr}</Text>
									</View>
								</TouchableHighlight>
							</View>
						) : null }

						{this.state.menuItemsCount > 0 || this.state.marketData.menuWebsite ? (
							<View>
								<View style={css.dl_market_date}>
									<Text style={css.dl_market_date_label}>Menu for {general.getTimestamp('mmmm d, yyyy')}</Text>
								</View>

								{this.state.menuItemsCount > 0 ? (
									<View>
										<View style={css.dl_market_filters_foodtype}>
											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.setTypeFilter('VT') }>
												{this.vegetarianFilterEnabled ? (
													<Text style={css.dining_card_filter_button_active}>Vegetarian</Text>
												) : (
													<Text style={css.dining_card_filter_button}>Vegetarian</Text>
												)}
											</TouchableHighlight>

											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.setTypeFilter('VG') }>
												{this.veganFilterEnabled ? (
													<Text style={css.dining_card_filter_button_active}>Vegan</Text>
												) : (
													<Text style={css.dining_card_filter_button}>Vegan</Text>
												)}
											</TouchableHighlight>
											
											<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.setTypeFilter('GF') }>
												{this.glutenfreeFilterEnabled ? (
													<Text style={css.dining_card_filter_button_active}>Gluten-free</Text>
												) : (
													<Text style={css.dining_card_filter_button}>Gluten-free</Text>
												)}
											</TouchableHighlight>
										</View>


										<View style={css.dl_market_filters_mealtype}>
											{this.mealFilter === 'breakfast' ? (
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
											{this.mealFilter === 'lunch' ? (
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
											{this.mealFilter === 'dinner' ? (
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
												{this.state.menuItemsActiveCount === 0 ? (
													<Text style={css.dl_noresults}>No results found matching your criteria.</Text>
												) : (
													<ListView
														dataSource={this.state.menuItemsActive}
														renderRow={ (rowData, sectionID, rowID, highlightRow) => {
															return (
																<TouchableHighlight key={rowID} style={css.dl_market_menu_row} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningNutrition(rowData) }>
																	<Text style={css.dl_menu_item_name}>{rowData.name}<Text style={css.dl_menu_item_price}> (${rowData.price})</Text></Text>
																</TouchableHighlight>
															)
														}}
													/>
												)}
											</View>
										) : (
											<View style={[css.card_center, css.card_loader]}>
												<ActivityIndicator size="large" />
											</View>
										)}
									</View>
								) : null }

								{this.state.menuItemsCount === 0 && this.state.marketData.menuWebsite ? (
									<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoMenuWebsite(this.state.marketData.menuWebsite) }>
										<View style={css.dd_menu_container}>
											{this.state.marketData.name.indexOf('Market') >= 0 ? (
												<Text style={css.dd_menu_text}>View To Go Menu</Text>
											) : (
												<Text style={css.dd_menu_text}>View Menu</Text>
											)}
										</View>
									</TouchableHighlight>
								) : null }

							</View>
						) : null }
					</View>
				</ScrollView>
			</View>
		);
	},

	setMealFilter: function(meal) {
		this.mealFilter = meal;
		this.parseMenuFilters();
	},

	setTypeFilter: function(type) {
		if (type === 'VT') {
			if (this.vegetarianFilterEnabled) {
				this.vegetarianFilterEnabled = false;
			} else {
				this.vegetarianFilterEnabled = true;
			}
		} else if (type === 'VG') {
			if (this.veganFilterEnabled) {
				this.veganFilterEnabled = false;
			} else {
				this.veganFilterEnabled = true;
			}
		} else if (type === 'GF') {
			if (this.glutenfreeFilterEnabled) {
				this.glutenfreeFilterEnabled = false;
			} else {
				this.glutenfreeFilterEnabled = true;
			}
		}
		this.parseMenuFilters();
	},

	parseMenuFilters: function() {

		var menuItemsArray = [],
			menuItemsActivated = [];

		if (this.mealFilter === 'breakfast') {
			menuItemsArray = this.state.menuItemsBreakfast;
		} else if (this.mealFilter === 'lunch') {
			menuItemsArray = this.state.menuItemsLunch;
		} else {
			menuItemsArray = this.state.menuItemsDinner;
		}

		if (!menuItemsArray) {
			menuItemsArray = [];
		} else if (this.vegetarianFilterEnabled || this.veganFilterEnabled || this.glutenfreeFilterEnabled) {
			for (var i = 0; menuItemsArray.length > i; i++) {
				if (this.vegetarianFilterEnabled && this.veganFilterEnabled && this.glutenfreeFilterEnabled) {
					if (menuItemsArray[i].tags.indexOf('VT') >= 0 && menuItemsArray[i].tags.indexOf('VG') >= 0 && menuItemsArray[i].tags.indexOf('GF') >= 0) {
						menuItemsActivated.push(menuItemsArray[i]);
					}
					continue;
				}
				if (this.vegetarianFilterEnabled && this.veganFilterEnabled) {
					if (menuItemsArray[i].tags.indexOf('VT') >= 0 && menuItemsArray[i].tags.indexOf('VG') >= 0) {
						menuItemsActivated.push(menuItemsArray[i]);
					}
					continue;
				}
				if (this.vegetarianFilterEnabled && this.glutenfreeFilterEnabled) {
					if (menuItemsArray[i].tags.indexOf('VT') >= 0 && menuItemsArray[i].tags.indexOf('GF') >= 0) {
						menuItemsActivated.push(menuItemsArray[i]);
					}
					continue;
				}
				if (this.veganFilterEnabled && this.glutenfreeFilterEnabled) {
					if (menuItemsArray[i].tags.indexOf('VG') >= 0 && menuItemsArray[i].tags.indexOf('GF') >= 0) {
						menuItemsActivated.push(menuItemsArray[i]);
					}
					continue;
				}
				if (this.vegetarianFilterEnabled && menuItemsArray[i].tags.indexOf('VT') >= 0) {
					menuItemsActivated.push(menuItemsArray[i]);
					continue;
				}
				if (this.veganFilterEnabled && menuItemsArray[i].tags.indexOf('VG') >= 0) {
					menuItemsActivated.push(menuItemsArray[i]);
					continue;
				}
				if (this.glutenfreeFilterEnabled && menuItemsArray[i].tags.indexOf('GF') >= 0) {
					menuItemsActivated.push(menuItemsArray[i]);
					continue;
				}
			}
		} else {
			menuItemsActivated = menuItemsArray;
		}

		var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

		this.setState({
			menuItemsActive: ds.cloneWithRows( menuItemsActivated ),
			menuItemsActiveCount: menuItemsActivated.length,
		});
	},

	gotoDiningNutrition: function(data) {
		this.props.navigator.push({ id: 'DiningNutrition', name: data.name, title: 'Nutrition', menuItem: data, component: DiningNutrition });
	},

	gotoMenuWebsite: function(url) {
		general.openURL(url);
	}

});

module.exports = DiningDetail;