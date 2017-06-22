import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	ScrollView,
	Image,
	ListView,
} from 'react-native';

import Icon from 'react-native-vector-icons/Ionicons';
import { Actions } from 'react-native-router-flux';

const css = require('../../styles/css');
const logger = require('../../util/logger');
const general = require('../../util/general');

const menuDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

class DiningDetail extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			filters: [],
			activeMeal: 'Breakfast',
		};
	}

	componentDidMount() {
		logger.ga('View Mounted: Dining Detail');
	}

	addFilter = (filter) => {
		if (filter === 'Breakfast' || filter === 'Lunch' || filter === 'Dinner') {
			this.setState({
				activeMeal: filter
			});
		} else {
			if (this.state.filters.indexOf(filter) < 0) {
				// Add filter
				this.setState({
					filters: [...this.state.filters, filter]
				});
			} else {
				// Remove filter
				const temp = [...this.state.filters];
				temp.splice(temp.indexOf(filter), 1);
				this.setState({
					filters: temp
				});
			}
		}
	}

	render() {
		const { data } = this.props;

		return (
			<View style={[css.main_container, css.whitebg]}>
				<ScrollView contentContainerStyle={[css.scroll_main, css.whitebg]}>
					<DiningDescription
						name={data.name}
						description={data.description}
						regularHours={data.regularHours}
						specialHours={data.specialHours}
					/>
					<DiningImages
						images={data.images}
					/>
					<DiningDirections
						latitude={data.coords.lat}
						longitude={data.coords.lon}
						distance={data.distanceMilesStr}
					/>
					<DiningMenu
						data={data}
						filters={this.state.filters}
						activeMeal={this.state.activeMeal}
						addFilter={(filter) => this.addFilter(filter)}
					/>
				</ScrollView>
			</View>
		);
	}
}

export default DiningDetail;

/*
	Presentational Components, should probably be moved out of this file
*/
const DiningDescription = ({ name, description, regularHours, specialHours }) => (
	<View style={css.dl_market_name}>
		<Text style={css.dl_market_name_text}>{name}</Text>
		{description ? (
			<Text style={css.dl_market_desc_text}>{description}</Text>
		) : null }
		{regularHours ? (
			<Text style={css.dl_market_desc_text}>{regularHours}</Text>
		) : null }
		{specialHours ? (
			<Text style={css.dl_market_desc_text}>Special Hours:{'\n'}{specialHours}</Text>
		) : null }
	</View>
);

const DiningImages = ({ images }) => (
	<View>
		{(images) ? (
			<ScrollView
				style={css.dl_market_scroller}
				directionalLockEnabled={false}
				horizontal={true}
			>
				{images.map((object, i) => (
					<Image
						key={i}
						style={css.dl_market_scroller_image}
						resizeMode={'cover'}
						source={{ uri: object }}
					/>
				))}
			</ScrollView>
		) : null }
	</View>
);

const DiningDirections = ({ latitude, longitude, distance }) => (
	<View>
		{latitude !== 0 && longitude !== 0 ? (
			<TouchableHighlight
				underlayColor={'rgba(200,200,200,.1)'}
				onPress={() => general.gotoNavigationApp(latitude, longitude)}
			>
				<View style={css.dl_market_directions}>
					<Text style={css.dl_dir_label}>Directions</Text>
					<View style={css.dl_dir_traveltype_container}>
						<Icon name="md-walk" size={32} color="#182B49" />
						{distance ? (
							<Text style={css.dl_dir_eta}>{distance}</Text>
						) : null }
					</View>
				</View>
			</TouchableHighlight>
		) : null }
	</View>
);

const DiningMenu = ({ data, filters, addFilter, activeMeal }) => {
	if (!data.menuItems && data.menuWebsite) {
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => general.openURL(data.menuWebsite)}>
				<View style={css.dd_menu_container}>
					{data.name.indexOf('Market') >= 0 ? (
						<Text style={css.dd_menu_text}>View To Go Menu</Text>
					) : (
						<Text style={css.dd_menu_text}>View Menu</Text>
					)}
				</View>
			</TouchableHighlight>
		);
	} else if (data.menuItems) {
		return (
			<View style={css.dd_dining_menu}>
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

const DiningMenuHeader = () => (
	<View style={css.dl_market_date}>
		<Text style={css.dl_market_date_label}>
			Menu for {general.getTimestamp('mmmm d, yyyy')}
		</Text>
	</View>
);

const MenuFilters = ({ filters, addFilter, activeMeal }) => (
	<View>
		<View style={css.dl_market_filters_foodtype}>
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
		<View style={css.dl_market_filters_mealtype}>
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
	<TouchableHighlight
		style={css.dl_meal_button}
		underlayColor={'rgba(200,200,200,.1)'}
		onPress={() => addFilter(name)}
	>
		{ (active === true) ?
			(<View style={css.dl_meal_button}>
				<View style={css.dl_mealtype_circle_active} />
				<Text style={css.dl_mealtype_label_active}>{name}</Text>
			</View>) :
			(<View style={css.dl_meal_button}>
				<View style={css.dl_mealtype_circle} />
				<Text style={css.dl_mealtype_label}>{name}</Text>
			</View>)
		}
	</TouchableHighlight>
);

/*
	VT, VG, GF
*/
const TypeButton = ({ name, type, active, addFilter }) => (
	<TouchableHighlight
		underlayColor={'rgba(200,200,200,.1)'}
		onPress={() => addFilter(type)}
	>
		{active ? (
			<Text style={css.dining_card_filter_button_active}>{name}</Text>
		) : (
			<Text style={css.dining_card_filter_button}>{name}</Text>
		)}
	</TouchableHighlight>
);

const MenuList = ({ data, filters, activeMeal }) => {
	if (Array.isArray(data) && Array.isArray(filters)) {
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
	<TouchableHighlight
		style={css.dl_market_menu_row}
		underlayColor={'rgba(200,200,200,.1)'}
		onPress={() => Actions.DiningNutrition({ menuItem: data })}
	>
		<Text style={css.dl_menu_item_name}>
			{data.name}
			<Text style={css.dl_menu_item_price}>
				(${data.price})
			</Text>
		</Text>
	</TouchableHighlight>
);
