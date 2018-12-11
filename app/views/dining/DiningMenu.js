import React from 'react'
import { View, Text, ActivityIndicator, FlatList } from 'react-native'
import { openURL } from '../../util/general'
import css from '../../styles/css'
import Touchable from '../common/Touchable'

const DiningMenu = ({
	navigation,
	requestStatus,
	data,
	menuUrl,
	filters,
	addFilter,
	activeMeal
}) => {
	if (menuUrl) {
		return (
			<Touchable
				onPress={() => openURL(menuUrl)}
			>
				<View style={css.dd_menu_link_container}>
					<Text style={css.dd_menu_link_text}>View Menu</Text>
				</View>
			</Touchable>
		)
	}
	else if (requestStatus) {
		return (
			<View style={css.dd_menu_container}>
				<ActivityIndicator
					animating={true}
					size="large"
				/>
			</View>
		)
	}
	else if (data && data.menuitems && data.menuitems.length > 1) {
		return (
			<View style={css.dd_menu_container}>
				<MenuFilters
					filters={filters}
					addFilter={addFilter}
					activeMeal={activeMeal}
				/>
				<MenuList
					navigation={navigation}
					filters={filters}
					data={data}
					activeMeal={activeMeal}
				/>
			</View>
		)
	}

	return null
}

const MenuFilters = ({ filters, addFilter, activeMeal }) => (
	<View>
		<View style={css.dd_menu_food_type}>
			<TypeButton
				name="Vegetarian"
				type="VT"
				active={filters.indexOf('VT') >= 0}
				addFilter={addFilter}
			/>
			<TypeButton
				name="Vegan"
				type="VG"
				active={filters.indexOf('VG') >= 0}
				addFilter={addFilter}
			/>
			<TypeButton
				name="Gluten-Free"
				type="GF"
				active={filters.indexOf('GF') >= 0}
				addFilter={addFilter}
			/>
		</View>
		<View style={css.dd_menu_meal_type}>
			<MealButton
				name="Breakfast"
				active={activeMeal === 'Breakfast'}
				addFilter={addFilter}
			/>
			<MealButton
				name="Lunch"
				active={activeMeal === 'Lunch'}
				addFilter={addFilter}
			/>
			<MealButton
				name="Dinner"
				active={activeMeal === 'Dinner'}
				addFilter={addFilter}
			/>
		</View>
	</View>
)

/*
	Breakfast, Lunch, Dinner
*/
const MealButton = ({ name, active, addFilter }) => (
	<Touchable
		style={css.dd_menu_meal_button}
		onPress={() => addFilter(name)}
	>
		{ (active === true) ?
			(
				<View style={css.dd_menu_meal_button}>
					<View style={css.dd_menu_circle_active} />
					<Text style={css.dd_menu_meal_type_text_active}>{name}</Text>
				</View>) :
			(
				<View style={css.dd_menu_meal_button}>
					<View style={css.dd_menu_circle} />
					<Text style={css.dd_menu_meal_type_text}>{name}</Text>
				</View>
			)
		}
	</Touchable>
)

/*
	VT, VG, GF
*/
const TypeButton = ({
	name,
	type,
	active,
	addFilter
}) => (
	<Touchable
		onPress={() => addFilter(type)}
	>
		{active ? (
			<Text style={css.dd_menu_filter_button_active}>{name}</Text>
		) : (
			<Text style={css.dd_menu_filter_button}>{name}</Text>
		)}
	</Touchable>
)

const MenuList = ({ navigation, data, filters, activeMeal }) => {
	const { disclaimer, disclaimerEmail, menuitems } = data
	if (Array.isArray(data.menuitems) && Array.isArray(filters)) {
		let filteredMenuItems = []

		// Active Meal filter
		filteredMenuItems = menuitems.filter((item) => {
			const itemTags = item.tags.toLowerCase()
			return ((itemTags.indexOf(activeMeal.toLowerCase()) >= 0) || (itemTags.indexOf(('ALL').toLowerCase()) >= 0))
		})

		// Food Type filters
		filters.forEach((tag) => {
			filteredMenuItems = filteredMenuItems.filter((item) => {
				const itemTags = item.tags.toLowerCase()
				return (itemTags.indexOf(tag.toLowerCase()) >= 0)
			})
		})

		return (
			<FlatList
				data={filteredMenuItems}
				keyExtractor={(listItem, index) => (listItem.itemID + index)}
				renderItem={({ item: rowData, index: rowID }) => (
					<MenuItem
						navigation={navigation}
						key={rowID}
						data={rowData}
						disclaimer={disclaimer}
						disclaimerEmail={disclaimerEmail}
					/>
				)}
			/>
		)
	} else {
		return null
	}
}

const MenuItem = ({ navigation, data, disclaimer, disclaimerEmail }) => (
	<Touchable
		style={css.dd_menu_row}
		onPress={() => navigation.navigate('DiningNutrition', { menuItem: data, disclaimer, disclaimerEmail })}
	>
		<Text style={css.dd_menu_item_name_text}>
			{data.name}<Text style={css.dd_menu_item_price_text}> (${data.price})</Text>
		</Text>
	</Touchable>
)

export default DiningMenu
