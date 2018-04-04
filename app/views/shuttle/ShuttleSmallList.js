import React from 'react';
import {
	View,
	Text,
	FlatList,
	StyleSheet
} from 'react-native';

import { getMinutesETA } from '../../util/shuttle';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';
import {
	COLOR_DGREY,
	COLOR_BLACK
} from '../../styles/ColorConstants';

const ShuttleSmallList = ({ arrivalData, rows, scrollEnabled }) => (
	<View
		style={styles.listContainer}
	>
		<Text style={styles.nextText}>
			Next Arrivals
		</Text>
		{(arrivalData) ? (
			<FlatList
				style={{ height: getRowHeight(rows) }}
				scrollEnabled={scrollEnabled}
				showsVerticalScrollIndicator={false}
				keyExtractor={(listItem, index) => (
					listItem.route.id +
					listItem.vehicle.id.toString()
				)}
				data={arrivalData}
				renderItem={
					({ item: rowData }) => (
						<ShuttleSmallRow
							arrival={rowData}
						/>
					)
				}
				enableEmptySections={true}
			/>
		) : (null)
		}
	</View>
);

const ShuttleSmallRow = ({ arrival }) => (
	<View style={styles.rowContainer}>
		<View style={[styles.circle, { backgroundColor: arrival.route.color }]}>
			<Text
				style={styles.shortNameText}
				allowFontScaling = {false}
			>
				{arrival.route.shortName}
			</Text>
		</View>
		<Text
			style={styles.nameText}
			numberOfLines={2}
		>
			{arrival.route.name}
		</Text>
		<Text style={styles.etaText}>{getMinutesETA(arrival.secondsToArrival)}</Text>
	</View>
);

function getRowHeight(rows) {
	const rowHeight = 40;
	const padding = 8;

	return rows * (rowHeight + padding);
}

const styles = StyleSheet.create({
	nextText: { fontSize: 20, fontWeight: '300', color: COLOR_BLACK, padding: 8 },
	rowContainer: { flexDirection: 'row', marginBottom: 8, marginHorizontal: 8, alignItems: 'center', justifyContent: 'flex-start' },
	circle: { borderRadius: 18, width: 36, height: 36, justifyContent: 'center', overflow: 'hidden' },
	shortNameText: { textAlign: 'center', fontWeight: '600', fontSize: 19, backgroundColor: 'transparent' },
	nameText: { flex: 4, fontSize: 15, color: COLOR_BLACK, marginLeft: 10 },
	etaText: { flex: 1.2, fontSize: 15, color: COLOR_DGREY, marginLeft: 10, textAlign: 'right' },
	listContainer: { width: MAX_CARD_WIDTH, overflow: 'hidden' },
});

export default ShuttleSmallList;
