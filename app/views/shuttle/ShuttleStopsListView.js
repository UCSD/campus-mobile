import React from 'react';
import {
	TouchableOpacity,
	Text,
	StyleSheet,
	ListView,
	View
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';
import css from '../../styles/css';
import {
	COLOR_MGREY,
	COLOR_DGREY
} from '../../styles/ColorConstants';

const resultsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleStopsListView = ({ navigation }) => {
	const { shuttle_stops, addStop } = navigation.state.params;
	return (
		<ListView
			style={css.main_full}
			dataSource={resultsDataSource.cloneWithRows(shuttle_stops)}
			renderRow={
				row => (
					<StopItem
						data={row}
						addStop={addStop}
					/>
				)
			}
		/>
	);
};

const StopItem = ({ data, addStop }) => (
	<TouchableOpacity
		onPress={() => addStop(data.id, data.name.trim())}
		style={styles.list_row}
		disabled={(data.saved === true)}
	>
		<Text style={(data.saved === true) ? (styles.row_name_disabled) : (styles.row_name)}>
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
	row_name_disabled: { color: COLOR_MGREY, flex: 1, paddingRight: 10 },
	list_row: { flex: 1, flexDirection: 'row', alignItems: 'center', height: 60, padding: 7, paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY, overflow: 'hidden' },
});

export default ShuttleStopsListView;
