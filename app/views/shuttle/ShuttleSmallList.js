import React from 'react';
import {
	View,
	Text,
	StyleSheet,
	ListView
} from 'react-native';

import { getPRM, round } from '../../util/general';
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
				{(arrival.route.shortName === 'Campus Loop') ?
					('L') : (arrival.route.shortName)
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
	const rowHeight = round(36 * getPRM());
	const padding = 16;

	return rows * (rowHeight + padding);
}

const styles = StyleSheet.create({
	shuttle_stop_next_arrivals_text: { fontSize: round(20 * getPRM()), fontWeight: '300', color: '#222', padding: 8 },
	shuttle_stop_arrivals_row: { flexDirection: 'row', padding: 8, alignItems: 'center', justifyContent: 'flex-start' },
	shuttle_stop_rt_2: { borderRadius: round(18 * getPRM()), width: round(36 * getPRM()), height: round(36 * getPRM()), justifyContent: 'center' },
	shuttle_stop_rt_2_label: { textAlign: 'center', fontWeight: '600', fontSize: round(19 * getPRM()), backgroundColor: 'rgba(0,0,0,0)' },
	shuttle_stop_arrivals_row_route_name: { flex: 2, fontSize: round(17 * getPRM()), color: '#555', paddingLeft: round(10 * getPRM()) },
	shuttle_stop_arrivals_row_eta_text: { flex: 1, fontSize: round(20 * getPRM()), color: '#333', paddingLeft: round(16 * getPRM()), paddingRight: round(16 * getPRM()) },
});

export default ShuttleSmallList;
