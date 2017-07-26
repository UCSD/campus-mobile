import React from 'react';
import {
	Switch,
	View,
	Text,
	StyleSheet,
	Dimensions,
	ListView,
	StatusBar,
	Platform,
	TouchableOpacity
} from 'react-native';
import ElevatedView from 'react-native-elevated-view';
import Icon from 'react-native-vector-icons/Ionicons';
import { COLOR_SECONDARY, COLOR_MGREY } from '../../styles/ColorConstants';
import { doPRM, getPRM, getMaxCardWidth } from '../../util/general';

const deviceHeight = Dimensions.get('window').height;
const statusBarHeight = Platform.select({
	ios: 0,
	android: StatusBar.currentHeight,
});
const resultsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const SearchShuttleMenu = ({ onToggle, toggles, shuttle_routes }) => (
	<ElevatedView
		style={styles.card_main}
		elevation={2}
	>
		<View style={styles.list_container}>
			{shuttle_routes ?
				(
					<MenuList
						shuttles={resultsDataSource.cloneWithRows(shuttle_routes)}
						onToggle={onToggle}
						toggles={toggles}
					/>
				) : (
					null
				)
			}
		</View>
	</ElevatedView>
);

const MenuList = ({ shuttles, onToggle, toggles }) => (
	<ListView
		dataSource={shuttles}
		renderRow={
			(row, sectionID, rowID) =>
				<MenuItem
					data={row}
					index={rowID}
					onToggle={onToggle}
					state={toggles[row.id]}
				/>
		}
	/>
);

const MenuItem = ({ data, index, onToggle, state }) => (
	<TouchableOpacity
		onPress={() => onToggle(data.id)}
		value={state}
		style={styles.list_row}
	>
		<Text style={{ flex: 4 }}>
			{data.name.trim()}
		</Text>
		<Icon
			style={styles.radio_icon}
			name={state ? 'ios-radio-button-on' : 'ios-radio-button-off'}
			size={20}
			color={COLOR_SECONDARY}
		/>
	</TouchableOpacity>
);

const navHeight = Platform.select({
	ios: 58,
	android: 44
});

// device - (statusBar + navHeight + searchBar + listPadding + tabBar)
const listHeight = deviceHeight - (statusBarHeight + navHeight + doPRM(44) + 16 + 40); // 18 + 64 + (44 * getPRM()));

const styles = StyleSheet.create({
	list_container: { width: getMaxCardWidth(), maxHeight: listHeight },
	card_main: { top: Math.round(44 * getPRM()) + 6, backgroundColor: 'white', margin: 6, alignItems: 'flex-start', justifyContent: 'center', },
	list_row: { alignItems: 'center', justifyContent: 'center', flexDirection: 'row', paddingVertical: 14, paddingHorizontal: 8, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, overflow: 'hidden',  },
	switch_container: { flex: 1, alignItems: 'flex-end' },
	radio_icon: { alignSelf: 'flex-end', marginLeft: 10 },
});

export default SearchShuttleMenu;
