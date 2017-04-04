import React from 'react';
import {
	TouchableOpacity,
	Text,
	StyleSheet,
	ListView,
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';
import css from '../../styles/css';

const resultsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleStopsListView = ({ shuttle_stops, addStop }) => (
	<ListView
		style={[css.main_container, css.scroll_main, css.whitebg]}
		dataSource={resultsDataSource.cloneWithRows(shuttle_stops)}
		renderRow={
			(row, sectionID, rowID) =>
				<MenuItem
					data={row}
					index={rowID}
					addStop={addStop}
				/>
		}
	/>
);

const MenuItem = ({ data, index, addStop }) => (
	<TouchableOpacity
		onPress={() => addStop(data.id)}
		style={styles.list_row}
	>
		<Text style={{ flex: 4 }}>
			{data.name.trim()}
		</Text>
		{
			(false) ? (
				<Icon
					style={{ flex: 1 }}
					name="check"
					size={20}
				/>
			) : (null)
		}
	</TouchableOpacity>
);

const styles = StyleSheet.create({
	list_row: { alignItems: 'center', flexDirection: 'row', padding: 7, paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', overflow: 'hidden' },
});

export default ShuttleStopsListView;
