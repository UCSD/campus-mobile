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

var DiningDetail = React.createClass({

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
		this.props.route.menuItem.nutrition.totalFatPct = Math.round(this.props.route.menuItem.nutrition.totalFat / 65 * 100);
		this.props.route.menuItem.nutrition.saturatedFatPct = Math.round(this.props.route.menuItem.nutrition.saturatedFat / 20 * 100);
		this.props.route.menuItem.nutrition.cholesterolPct = Math.round(this.props.route.menuItem.nutrition.cholesterol / 300 * 100);
		this.props.route.menuItem.nutrition.sodiumPct = Math.round(this.props.route.menuItem.nutrition.sodium / 2400 * 100);
		this.props.route.menuItem.nutrition.totalCarbohydratePct = Math.round(this.props.route.menuItem.nutrition.totalCarbohydrate / 300 * 100);
		this.props.route.menuItem.nutrition.dietaryFiberPct = Math.round(this.props.route.menuItem.nutrition.dietaryFiber / 25 * 100);
		this.props.route.menuItem.nutrition.proteinPct = Math.round(this.props.route.menuItem.nutrition.protein / 50 * 100);

		return {
			menuItem: this.props.route.menuItem
		};
	},

	render: function() {
		return this.renderScene();
	},

	renderScene: function() {
		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>

					<View style={css.dl_market_name}>
						<Text style={css.dl_market_name_text}>{this.state.menuItem.station}</Text>
						<Text style={css.dd_menu_item_name}>{this.state.menuItem.name}</Text>
					</View>

					<View style={css.ddn_container}>
						<Text style={css.ddn_header}>Nutrition Facts</Text>
						<Text style={css.ddn_servingsize}>Serving Size {this.state.menuItem.nutrition.servingSize}</Text>
						<View style={css.ddn_topborder1}><Text style={css.ddn_amountperserving}>Amount Per Serving</Text></View>
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Calories</Text> {this.state.menuItem.nutrition.calories}</Text></View>
						<View style={css.ddn_topborder2}><Text style={css.ddn_dv}>% Daily Values*</Text></View>
						
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Total Fat</Text> 10g</Text><Text style={css.ddn_percent}>15%</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Saturated Fat {this.state.menuItem.nutrition.saturatedFat}g</Text><Text style={css.ddn_percent}>25%</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Trans Fat {this.state.menuItem.nutrition.transFat}g</Text><Text style={css.ddn_percent}></Text></View>

						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Cholesterol</Text> {this.state.menuItem.nutrition.cholesterol}mg</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.cholesterolPct}%</Text></View>
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Sodium</Text> {this.state.menuItem.nutrition.sodium}g</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.sodiumPct}%</Text></View>
						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Total Carbohydrate</Text> {this.state.menuItem.nutrition.totalCarbohydrate}g</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.totalCarbohydratePct}%</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Dietary Fiber {this.state.menuItem.nutrition.dietaryFiber}g</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.dietaryFiberPct}%</Text></View>
							<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Sugars {this.state.menuItem.nutrition.sugars}g</Text><Text style={css.ddn_percent}></Text></View>

						<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Protein</Text> {this.state.menuItem.nutrition.protein}g</Text><Text style={css.ddn_percent}>{this.state.menuItem.nutrition.proteinPct}%</Text></View>

						<View style={css.ddn_topborder1}><Text style={css.ddn_dv_amountperserving}>*Percent Daily Values are based on a 2,000 calorie diet.</Text></View>
					</View>

				</ScrollView>
			</View>
		);
	},
});

module.exports = DiningDetail;