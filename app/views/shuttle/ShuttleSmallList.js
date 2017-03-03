import React from 'react';
import {
	View,
	Text,
	ListView,
} from 'react-native';

import { getMinutesETA } from '../../util/shuttle';
import css from '../../styles/css';

const arrivalDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleSmallList = ({ arrivalData, style, rows, scrollEnabled }) => (
	<View
		style={style}
	>
		<Text style={css.sc_next_arrivals_text}>
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
	<View style={css.sc_arrivals_row}>
		<View style={[css.sc_rt_2, { backgroundColor: arrival.route.color, borderColor: arrival.route.color }]}>
			<Text style={css.sc_rt_2_label}>
				{
					// THIS SHOULDN'T BE NEEDED, complain to syncromatics
					arrival.route.shortName.replace(/[()]/g, '').substring(0, 1) // Limits shortName to one char
				}
			</Text>
		</View>
		<Text
			style={css.sc_arrivals_row_route_name}
			numberOfLines={2}
		>
			{arrival.route.name}
		</Text>
		<Text style={css.sc_arrivals_row_eta_text}>{getMinutesETA(arrival.secondsToArrival)}</Text>
	</View>
);

function getRowHeight(rows) {
	const rowHeight = 40;
	const padding = 8;

	return rows * (rowHeight + padding);
}


export default ShuttleSmallList;
