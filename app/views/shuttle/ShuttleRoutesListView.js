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

const ShuttleRoutesListView = ({ shuttle_routes, gotoStopsList }) => {
	return (
		<ListView
			style={[css.main_container, css.scroll_main, css.whitebg]}
			dataSource={resultsDataSource.cloneWithRows(shuttle_routes)}
			renderRow={
				(row) =>
					<RouteItem
						data={row}
						gotoStopsList={gotoStopsList}
					/>
			}
		/>
	);
};

const RouteItem = ({ data, index, gotoStopsList }) => (
	<View
		style={styles.list_row}
	>
		<TouchableOpacity
			onPress={() => gotoStopsList(data.stops)}
			style={styles.touchable}
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
	</View>
);

const styles = StyleSheet.create({
	touchable: { flex: 1 },
	list_row: { flex: 1, alignItems: 'center', flexDirection: 'row', padding: 7, paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#EEE', overflow: 'hidden' },
});

export default ShuttleRoutesListView;
