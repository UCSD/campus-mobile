import React from 'react';
import {
	TouchableOpacity,
	Text,
	StyleSheet,
	FlatList,
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';
import css from '../../styles/css';
import {
	COLOR_MGREY,
	COLOR_DGREY
} from '../../styles/ColorConstants';

const ShuttleRoutesListView = ({ navigation }) => {
	const { shuttle_routes, gotoStopsList } = navigation.state.params;
	return (
		<FlatList
			style={css.main_full}
			data={shuttle_routes}
			keyExtractor={(listItem, index) => (
				listItem.id
			)}
			renderItem={
				({ item: rowData }) => (
					<RouteItem
						data={rowData}
						gotoStopsList={gotoStopsList}
					/>
				)
			}
		/>
	);
};

const RouteItem = ({ data, gotoStopsList }) => (
	<TouchableOpacity
		onPress={() => gotoStopsList(data.stops)}
		style={styles.touchable}
	>
		<Text style={styles.row_name}>
			{data.name.trim()}
		</Text>
		<Icon
			style={styles.icon}
			name="chevron-right"
			size={20}
		/>
	</TouchableOpacity>
);

const styles = StyleSheet.create({
	icon: { alignSelf: 'flex-end', color: COLOR_DGREY },
	row_name: { flex: 1, paddingRight: 10 },
	touchable: { flex: 1, flexDirection: 'row', alignItems: 'center', height: 60, padding: 7, paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, overflow: 'hidden' },
});

export default ShuttleRoutesListView;
