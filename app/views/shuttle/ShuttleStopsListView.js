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

const resultsDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleStopsListView = ({ shuttle_stops, addStop }) => (
	<ListView
		style={[css.main_container, css.scroll_main, css.whitebg]}
		dataSource={resultsDataSource.cloneWithRows(shuttle_stops)}
		renderRow={
			(row) =>
				<StopItem
					data={row}
					addStop={addStop}
				/>
		}
	/>
);

const StopItem = ({ data, addStop }) => (
	<View
		style={styles.list_row}
	>
		<TouchableOpacity
			onPress={() => addStop(data.id, data.name.trim())}
			style={styles.touchable}
		>
			<Text style={styles.row_name}>
				{data.name.trim()}
			</Text>
			<Icon
				style={styles.icon}
				color="rgba(116,118,120,.6)"
				name="chevron-right"
				size={20}
			/>
		</TouchableOpacity>
	</View>
);

const styles = StyleSheet.create({
	icon: { alignSelf: 'flex-end' },
	touchable: { flex: 1, flexDirection: 'row', alignItems: 'center' },
	row_name: { flex: 1, paddingRight: 10 },
	list_row: { flex: 1, height: 60, padding: 7, paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', overflow: 'hidden' },
});

export default ShuttleStopsListView;
