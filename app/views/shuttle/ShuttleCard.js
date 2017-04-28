import React from 'react';
import {
	StyleSheet,
	Text,
	TouchableHighlight
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import ShuttleOverview from './ShuttleOverview';
import ScrollCard from '../card/ScrollCard';

import { doPRM, getMaxCardWidth, getCampusPrimary } from '../../util/general';

const ShuttleCard = ({ stopsData, savedStops, gotoRoutesList, gotoSavedList, updateScroll, lastScroll }) => {
	const extraActions = [
		{
			name: 'Manage Stops',
			action: gotoSavedList
		}
	];

	return (
		<ScrollCard
			id="shuttle"
			title="Shuttle"
			scrollData={savedStops}
			renderRow={
				(row) =>
					<ShuttleOverview
						onPress={() => Actions.ShuttleStop({ stopID: row.id })}
						stopData={stopsData[row.id]}
						closest={Object.prototype.hasOwnProperty.call(row, 'savedIndex')}
					/>
			}
			actionButton={
				<TouchableHighlight
					style={styles.add_container}
					underlayColor={'rgba(200,200,200,.1)'}
					onPress={() => gotoRoutesList()}
				>
					<Text style={styles.add_label}>Add a Stop</Text>
				</TouchableHighlight>
			}
			extraActions={extraActions}
			updateScroll={updateScroll}
			lastScroll={lastScroll}
		/>
	);
};

export default ShuttleCard;

// There's gotta be a better way to do this...find a way to get rid of magic numbers
const nextArrivals = ((2 * doPRM(36)) + 32) + doPRM(20); // Two rows + text
const cardHeader = 26; // font + padding
const cardBody = doPRM(83) + (2 * doPRM(20)) + doPRM(26) + 20; // top + margin + font + padding

const styles = StyleSheet.create({
	add_container: { width: getMaxCardWidth(), backgroundColor: '#F9F9F9', alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingVertical: 8, borderTopWidth: 1, borderBottomWidth: 1, borderColor: '#DDD' },
	add_label: { fontSize: 20, color: getCampusPrimary(), fontWeight: '300' },
	shuttle_card_row_center: { alignItems: 'center', justifyContent: 'center', width: getMaxCardWidth() },
	shuttle_card_loader: { height: nextArrivals + cardHeader + cardBody },
	shuttlecard_loading_fail: { marginHorizontal: doPRM(16), marginTop: doPRM(40), marginBottom: doPRM(60) },
	fs18: { fontSize: doPRM(18) },
	pt10: { paddingTop: 10 },
	fs12: { fontSize: doPRM(12) },
	dgrey: { color: '#333' },
});
