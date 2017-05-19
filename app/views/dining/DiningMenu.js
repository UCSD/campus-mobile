import React from 'react';
import {
	View,
	Text,
	StyleSheet,
	ListView
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import {
	openURL,
} from '../../util/general';
import {
	COLOR_PRIMARY,
	COLOR_WHITE,
	COLOR_MGREY,
	COLOR_DGREY
} from '../../styles/ColorConstants';
import Touchable from '../common/Touchable';

const menuDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const DiningMenu = ({ data, filters, addFilter, activeMeal }) => {
	if (!data.menuItems && data.menuWebsite) {
		return (
			<Touchable
				onPress={() => openURL(data.menuWebsite)}
			>
				<View style={styles.linkContainer}>
					{data.name.indexOf('Market') >= 0 ? (
						<Text style={styles.linkText}>View To Go Menu</Text>
					) : (
						<Text style={styles.linkText}>View Menu</Text>
					)}
				</View>
			</Touchable>
		);
	} else if (data.menuItems) {
		return (
			<View style={styles.menuContainer}>
				<MenuFilters
					filters={filters}
					addFilter={addFilter}
					activeMeal={activeMeal}
				/>
				<MenuList
					filters={filters}
					data={data.menuItems}
					activeMeal={activeMeal}
				/>
			</View>
		);
	} else {
		return null;
	}
};

/* Not used rn
const DiningMenuHeader = () => (
	<View style={styles.dl_market_date}>
		<Text style={styles.dl_market_date_label}>
			Menu for {getTimestamp('mmmm d, yyyy')}
		</Text>
	</View>
);*/

const MenuFilters = ({ filters, addFilter, activeMeal }) => (
	<View>
		<View style={styles.foodType}>
			<TypeButton
				name={'Vegetarian'}
				type={'VT'}
				active={filters.indexOf('VT') >= 0}
				addFilter={addFilter}
			/>
			<TypeButton
				name={'Vegan'}
				type={'VG'}
				active={filters.indexOf('VG') >= 0}
				addFilter={addFilter}
			/>
			<TypeButton
				name={'Gluten-Free'}
				type={'GF'}
				active={filters.indexOf('GF') >= 0}
				addFilter={addFilter}
			/>
		</View>
		<View style={styles.mealType}>
			<MealButton
				name={'Breakfast'}
				active={activeMeal === 'Breakfast'}
				addFilter={addFilter}
			/>
			<MealButton
				name={'Lunch'}
				active={activeMeal === 'Lunch'}
				addFilter={addFilter}
			/>
			<MealButton
				name={'Dinner'}
				active={activeMeal === 'Dinner'}
				addFilter={addFilter}
			/>
		</View>
	</View>
);

/*
	Breakfast, Lunch, Dinner
*/
const MealButton = ({ name, active, addFilter }) => (
	<Touchable
		style={styles.mealButton}
		onPress={() => addFilter(name)}
	>
		{ (active === true) ?
			(<View style={styles.mealButton}>
				<View style={styles.circleActive} />
				<Text style={styles.mealTypeTextActive}>{name}</Text>
			</View>) :
			(<View style={styles.mealButton}>
				<View style={styles.circle} />
				<Text style={styles.mealTypeText}>{name}</Text>
			</View>)
		}
	</Touchable>
);

/*
	VT, VG, GF
*/
const TypeButton = ({ name, type, active, addFilter }) => (
	<Touchable
		onPress={() => addFilter(type)}
	>
		{active ? (
			<Text style={styles.filterButtonActive}>{name}</Text>
		) : (
			<Text style={styles.filterButton}>{name}</Text>
		)}
	</Touchable>
);

const MenuList = ({ data, filters, activeMeal }) => {
	if (data) {
		let menuItems = [];

		// Active Meal filter
		menuItems = data.filter((item) => {
			const itemTags = item.tags.toLowerCase();
			return ((itemTags.indexOf(activeMeal.toLowerCase()) >= 0) || (itemTags.indexOf(('ALL DAY').toLowerCase()) >= 0));
		});

		// Food Type filters
		filters.forEach((tag) => {
			menuItems = menuItems.filter((item) => {
				const itemTags = item.tags.toLowerCase();
				return (itemTags.indexOf(tag.toLowerCase()) >= 0);
			});
		});

		return (
			<ListView
				dataSource={menuDataSource.cloneWithRows(menuItems)}
				renderRow={(rowData, sectionID, rowID, highlightRow) => (
					<MenuItem
						key={rowID}
						data={rowData}
					/>
				)}
			/>
		);
	} else {
		return null;
	}
};

const MenuItem = ({ data }) => (
	<Touchable
		style={styles.menuRow}
		onPress={() => Actions.DiningNutrition({ menuItem: data })}
	>
		<Text style={styles.itemNameText}>
			{data.name}
			<Text style={styles.itemPriceText}>
				(${data.price})
			</Text>
		</Text>
	</Touchable>
);

const styles = StyleSheet.create({
	linkContainer: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, margin: 20, padding: 10 },
	menuContainer: { marginHorizontal: 8 },
	linkText: { fontSize: 16, color: COLOR_WHITE },
	foodType: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginVertical: 8 },
	mealType: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', borderTopWidth: 1, borderTopColor: COLOR_MGREY, },
	filterButton: { paddingVertical: 8, paddingHorizontal: 14, fontSize: 14, color: COLOR_DGREY, borderWidth: 1, borderColor: COLOR_DGREY, borderRadius: 3, backgroundColor: COLOR_MGREY, textAlign: 'center', marginHorizontal: 8 },
	filterButtonActive: { paddingVertical: 8, paddingHorizontal: 14, fontSize: 14, color: COLOR_WHITE, borderWidth: 1, borderColor: COLOR_DGREY, borderRadius: 3, backgroundColor: COLOR_PRIMARY, textAlign: 'center', marginHorizontal: 8, overflow: 'hidden' },
	circle: { borderWidth: 1, borderColor: COLOR_MGREY, borderRadius: 8, width: 16, height: 16, backgroundColor: COLOR_MGREY, marginRight: 5 },
	circleActive: { borderWidth: 1, borderColor: COLOR_MGREY, borderRadius: 8, width: 16, height: 16, backgroundColor: COLOR_PRIMARY, marginRight: 5 },
	mealTypeText: { fontSize: 20, color: COLOR_DGREY, },
	mealTypeTextActive: { fontSize: 20, color: COLOR_PRIMARY, },
	menuRow: { flexDirection: 'row', paddingBottom: 8 },
	itemNameText: { fontSize: 15, color: COLOR_PRIMARY },
	itemPriceText: { color: COLOR_DGREY, paddingLeft: 26, marginLeft: 30 },
	mealButton: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', height: 40, },
});

export default DiningMenu;
