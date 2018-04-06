import React from 'react'
import { View, Text, ScrollView } from 'react-native'

import { openURL } from '../../util/general'
import Touchable from '../common/Touchable'
import logger from '../../util/logger'
import css from '../../styles/css'

const DiningNutrition = ({ navigation }) => {
	const { params } = navigation.state
	const { menuItem, disclaimer, disclaimerEmail } = params
	logger.ga('View Loaded: Dining Nutrition: ' + menuItem.name )

	return (
		<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
			<View style={css.dn_market_name}>
				{menuItem.station ? (<Text style={css.dn_market_name_text}>{menuItem.station}</Text>) : null }
				<Text style={css.dn_menu_item_name}>{menuItem.name}</Text>
			</View>

			<View style={css.dn_container}>
				<Text style={css.dn_header}>Nutrition Facts</Text>
				<Text style={css.dn_servingsize}>Serving Size {menuItem.nutrition.servingSize}</Text>
				<View style={css.dn_topborder1}><Text style={css.dn_amountperserving}>Amount Per Serving</Text></View>
				<View style={css.dn_row_main}><Text style={css.dn_font}><Text style={css.dn_bold}>Calories</Text> {menuItem.nutrition.calories}</Text></View>
				<View style={css.dn_topborder2}><Text style={css.dn_dv}>% Daily Values*</Text></View>

				<View style={css.dn_row_main}><Text style={css.dn_font}><Text style={css.dn_bold}>Total Fat</Text> {menuItem.nutrition.totalFat}</Text><Text style={css.dn_percent}>{menuItem.nutrition.totalFat_DV}</Text></View>
				<View style={css.dn_row_sub}><Text style={css.dn_font}>Saturated Fat {menuItem.nutrition.saturatedFat}</Text><Text style={css.dn_percent}>{menuItem.nutrition.saturatedFat_DV}</Text></View>
				<View style={css.dn_row_sub}>
					<Text style={css.dn_font}>Trans Fat {menuItem.nutrition.transFat}</Text><Text style={css.dn_percent}>
						{menuItem.nutrition.transFatDV !== '%' ? menuItem.nutrition.transFatDV : null }
					</Text>
				</View>

				<View style={css.dn_row_main}><Text style={css.dn_font}><Text style={css.dn_bold}>Cholesterol</Text> {menuItem.nutrition.cholesterol}</Text><Text style={css.dn_percent}>{menuItem.nutrition.cholesterol_DV}</Text></View>
				<View style={css.dn_row_main}><Text style={css.dn_font}><Text style={css.dn_bold}>Sodium</Text> {menuItem.nutrition.sodium}</Text><Text style={css.dn_percent}>{menuItem.nutrition.sodium_DV}</Text></View>
				<View style={css.dn_row_main}><Text style={css.dn_font}><Text style={css.dn_bold}>Total Carbohydrate</Text> {menuItem.nutrition.totalCarbohydrate}</Text><Text style={css.dn_percent}>{menuItem.nutrition.totalCarbohhdrate_DV}</Text></View>
				<View style={css.dn_row_sub}><Text style={css.dn_font}>Dietary Fiber {menuItem.nutrition.dietaryFiber}</Text><Text style={css.dn_percent}>{menuItem.nutrition.dietaryFiber_DV}</Text></View>
				<View style={css.dn_row_sub}><Text style={css.dn_font}>Sugars {menuItem.nutrition.sugars}</Text>
					<Text style={css.dn_percent}></Text>
				</View>

				<View style={css.dn_row_main}><Text style={css.dn_font}><Text style={css.dn_bold}>Protein</Text> {menuItem.nutrition.protein}</Text><Text style={css.dn_percent}>{menuItem.nutrition.protein_DV}</Text></View>

				<View style={css.dn_topborder1}><Text style={css.dn_dv_amountperserving}>*Percent Daily Values are based on a 2,000 calorie diet.</Text></View>
			</View>

			{
				(menuItem.nutrition.ingredients) ? (
					<View style={css.dn_info_container}>
						<Text>
							<Text style={css.dn_bold}>Ingredients: </Text>
							<Text style={css.dn_font}>{menuItem.nutrition.ingredients}</Text>
						</Text>
					</View>
				) : (null)
			}

			<View style={css.dn_info_container}>
				<Text>
					<Text style={css.dn_bold}>Allergens: </Text>
					{
						(menuItem.nutrition.allergens) ? (
							<Text style={css.dn_font}>{menuItem.nutrition.allergens}</Text>
						) : (
							<Text style={css.dn_font}>None</Text>
						)
					}
				</Text>
			</View>

			<View style={css.dn_info_container}>
				<Text>
					<Text style={css.dn_bold}>Disclaimer: </Text>
					<Text style={css.dn_disclaimer_font}>{disclaimer}</Text>
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
	)
}

const DisclaimerEmailButton = ({ disclaimerEmail }) => (
	<Touchable
		onPress={() => openURL(`mailto:${disclaimerEmail}`)}
	>
		<View style={css.dd_menu_link_container}>
			<Text style={css.dd_menu_link_text}>Contact Nutrition Team</Text>
		</View>
	</Touchable>
)

export default DiningNutrition
