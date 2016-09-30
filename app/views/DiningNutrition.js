'use strict';

import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	ListView
} from 'react-native';
 
var logger = require('../util/logger');
var css = require('../styles/css');

var DiningNutrition = React.createClass({

	getInitialState: function() {
		/*
			FDA Daily Nutritional Allowances
			Fat: 			65g
			Saturated Fat: 	20g
			Cholesterol: 	300mg
			Sodium: 		2400mg
			Carbs: 			300g
			Fiber: 			25g
			Protein: 		50g
		*/
		
		return {
			menuItem: this.props.route.menuItem
		};
	},

	componentDidMount: function() {
		logger.ga('View Loaded: Dining Nutrition: ' + this.state.menuItem.name );
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>

					<View style={css.dl_market_name}>
						{this.state.menuItem.station ? (<Text style={css.dl_market_name_text}>{this.state.menuItem.station}</Text>) : null }
						<Text style={css.dd_menu_item_name}>{this.state.menuItem.name}</Text>
					</View>

					<View style={css.ddn_container}>
						<Text style={css.ddn_header}>Nutrition Facts</Text>
						<Text style={css.ddn_servingsize}>Serving Size {this.state.menuItem.nutrition.servingSize}</Text>
						<View style={css.ddn_topborder1}><Text style={css.ddn_amountperserving}>Amount Per Serving</Text></View>
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Calories</Text> {this.state.menuItem.nutrition.calories}</Text></View>
						<View style={css.ddn_topborder2}><Text style={css.ddn_dv}>% Daily Values*</Text></View>
						
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Total Fat</Text> {this.state.menuItem.nutrition.totalFat}</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.totalFatDV}</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Saturated Fat {this.state.menuItem.nutrition.saturatedFat}</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.saturatedFatDV}</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Trans Fat {this.state.menuItem.nutrition.transFat}</Text><Text style={css.ddn_percent}>
								{this.state.menuItem.nutrition.transFatDV !== '%' ? this.state.menuItem.nutrition.transFatDV : null }
							</Text></View>

						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Cholesterol</Text> {this.state.menuItem.nutrition.cholesterol}</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.cholesterolDV}</Text></View>
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Sodium</Text> {this.state.menuItem.nutrition.sodium}</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.sodiumDV}</Text></View>
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Total Carbohydrate</Text> {this.state.menuItem.nutrition.totalCarbohydrate}</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.totalCarbohydrateDV}</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Dietary Fiber {this.state.menuItem.nutrition.dietaryFiber}</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.dietaryFiberDV}</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Sugars {this.state.menuItem.nutrition.sugars}</Text><Text style={css.ddn_percent}></Text></View>

						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Protein</Text> {this.state.menuItem.nutrition.protein}</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.proteinDV}</Text></View>

						<View style={css.ddn_topborder1}><Text style={css.ddn_dv_amountperserving}>*Percent Daily Values are based on a 2,000 calorie diet.</Text></View>
					</View>

				</ScrollView>
			</View>
		);
	},
});

module.exports = DiningNutrition;