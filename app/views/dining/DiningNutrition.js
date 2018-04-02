import React from 'react';
import {
	View,
	Text,
	ScrollView,
} from 'react-native';

import {
	openURL,
} from '../../util/general';
import Touchable from '../common/Touchable';

const logger = require('../../util/logger');
const css = require('../../styles/css');

const DiningNutrition = ({ navigation }) => {
	const { params } = navigation.state;
	const { menuItem, disclaimer, disclaimerEmail } = params;
	logger.ga('View Loaded: Dining Nutrition: ' + menuItem.name );

	return (
		<View style={css.main_full}>
			<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>

				<View style={css.ddn_market_name}>
					{menuItem.station ? (<Text style={css.ddn_market_name_text}>{menuItem.station}</Text>) : null }
					<Text style={css.ddn_menu_item_name}>{menuItem.name}</Text>
				</View>

				<View style={css.ddn_container}>
					<Text style={css.ddn_header}>Nutrition Facts</Text>
					<Text style={css.ddn_servingsize}>Serving Size {menuItem.nutrition.servingSize}</Text>
					<View style={css.ddn_topborder1}><Text style={css.ddn_amountperserving}>Amount Per Serving</Text></View>
					<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Calories</Text> {menuItem.nutrition.calories}</Text></View>
					<View style={css.ddn_topborder2}><Text style={css.ddn_dv}>% Daily Values*</Text></View>

					<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Total Fat</Text> {menuItem.nutrition.totalFat}</Text><Text style={css.ddn_percent}>{menuItem.nutrition.totalFatDV}</Text></View>
					<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Saturated Fat {menuItem.nutrition.saturatedFat}</Text><Text style={css.ddn_percent}>{menuItem.nutrition.saturatedFatDV}</Text></View>
					<View style={css.ddn_row_sub}>
						<Text style={css.ddn_font}>Trans Fat {menuItem.nutrition.transFat}</Text><Text style={css.ddn_percent}>
							{menuItem.nutrition.transFatDV !== '%' ? menuItem.nutrition.transFatDV : null }
						</Text>
					</View>

					<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Cholesterol</Text> {menuItem.nutrition.cholesterol}</Text><Text style={css.ddn_percent}>{menuItem.nutrition.cholesterolDV}</Text></View>
					<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Sodium</Text> {menuItem.nutrition.sodium}</Text><Text style={css.ddn_percent}>{menuItem.nutrition.sodiumDV}</Text></View>
					<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Total Carbohydrate</Text> {menuItem.nutrition.totalCarbohydrate}</Text><Text style={css.ddn_percent}>{menuItem.nutrition.totalCarbohydrateDV}</Text></View>
					<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Dietary Fiber {menuItem.nutrition.dietaryFiber}</Text><Text style={css.ddn_percent}>{menuItem.nutrition.dietaryFiberDV}</Text></View>
					<View style={css.ddn_row_sub}><Text style={css.ddn_font}>Sugars {menuItem.nutrition.sugars}</Text><Text style={css.ddn_percent}></Text></View>

					<View style={css.ddn_row_main}><Text style={css.ddn_font}><Text style={css.bold}>Protein</Text> {menuItem.nutrition.protein}</Text><Text style={css.ddn_percent}>{menuItem.nutrition.proteinDV}</Text></View>

					<View style={css.ddn_topborder1}><Text style={css.ddn_dv_amountperserving}>*Percent Daily Values are based on a 2,000 calorie diet.</Text></View>
				</View>

				{
					(menuItem.nutrition.ingredients) ? (
						<View style={css.ddn_info_container}>
							<Text>
								<Text style={css.ddn_bold}>Ingredients: </Text>
								<Text style={css.ddn_font}>{menuItem.nutrition.ingredients}</Text>
							</Text>
						</View>
					) : (null)
				}

				<View style={css.ddn_info_container}>
					<Text>
						<Text style={css.ddn_bold}>Allergens: </Text>
						{
							(menuItem.nutrition.allergens) ? (
								<Text style={css.ddn_font}>{menuItem.nutrition.allergens}</Text>
							) : (
								<Text style={css.ddn_font}>None</Text>
							)
						}
					</Text>
				</View>

				<View style={css.ddn_info_container}>
					<Text>
						<Text style={css.ddn_bold}>Disclaimer: </Text>
						<Text style={css.ddn_disclaimer_font}>{disclaimer}</Text>
					</Text>
				</View>
				{
					(disclaimerEmail) ? (
						<DisclaimerEmailButton
							disclaimerEmail={disclaimerEmail}
						/>
					) : (null)
				}
			</ScrollView>
		</View>
	);
};

const DisclaimerEmailButton = ({ disclaimerEmail }) => (
	<Touchable
		onPress={() => openURL(`mailto:${disclaimerEmail}`)}
	>
		<View style={css.dd_menu_link_container}>
			<Text style={css.dd_menu_link_text}>Contact Nutrition Team</Text>
		</View>
	</Touchable>
);

export default DiningNutrition;
