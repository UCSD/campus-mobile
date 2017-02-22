import React from 'react';
import {
	View,
	Text,
	StyleSheet,
	ListView
} from 'react-native';

import { getMinutesETA } from '../../util/shuttle';

const arrivalDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleSmallList = ({ arrivalData, style, rows, scrollEnabled }) => (
	<View
		style={style}
	>
		<Text style={styles.shuttle_stop_next_arrivals_text}>
			Next Arrivals
		</Text>
		<View
			style={{ height: getRowHeight(rows) }}
		>
			<ListView
				scrollEnabled={scrollEnabled}
				showsVerticalScrollIndicator={false}
				dataSource={arrivalDataSource.cloneWithRows(arrivalData)}
				renderRow={
					(row, sectionID, rowID) =>
						<ShuttleSmallRow
							arrival={row}
						/>
				}
			/>
		</View>
	</View>
);

const ShuttleSmallRow = ({ arrival }) => (
	<View style={styles.shuttle_stop_arrivals_row}>
		<View style={[styles.shuttle_stop_rt_2, { backgroundColor: arrival.route.color, borderColor: arrival.route.color }]}>
			<Text style={styles.shuttle_stop_rt_2_label}>
				{
					// THIS SHOULDN'T BE NEEDED, complain to syncromatics
					arrival.route.shortName.replace(/[()]/g, '').substring(0, 1) // Limits shortName to one char
				}
			</Text>
		</View>
		<Text
			style={styles.shuttle_stop_arrivals_row_route_name}
			numberOfLines={1}
		>
			{arrival.route.name}
		</Text>
		<Text style={styles.shuttle_stop_arrivals_row_eta_text}>{getMinutesETA(arrival.secondsToArrival)}</Text>
	</View>
);

function getRowHeight(rows) {
	const rowHeight = 36;
	const padding = 16;

	return rows * (rowHeight + padding);
}

const styles = StyleSheet.create({
	shuttle_stop_next_arrivals_text: { fontSize: 20, fontWeight: '300', color: '#222', padding: 8 },
	shuttle_stop_arrivals_row: { flexDirection: 'row', padding: 8, alignItems: 'center', justifyContent: 'flex-start' },
	shuttle_stop_rt_2: { borderRadius: 18, width: 36, height: 36, justifyContent: 'center' },
	shuttle_stop_rt_2_label: { textAlign: 'center', fontWeight: '600', fontSize: 19, backgroundColor: 'rgba(0,0,0,0)' },
	shuttle_stop_arrivals_row_route_name: { flex: 2, fontSize: 17, color: '#555', paddingLeft: 10 },
	shuttle_stop_arrivals_row_eta_text: { flex: 1, fontSize: 20, color: '#333', paddingLeft: 16, paddingRight: 16 },
});

export default ShuttleSmallList;
