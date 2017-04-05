import React from 'react';
import {
	View,
	ActivityIndicator,
	StyleSheet,
	Text,
	TouchableHighlight
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import ShuttleOverview from './ShuttleOverview';
import ScrollCard from '../card/ScrollCard';
import ShuttleOverviewList from './ShuttleOverviewList';
import LocationRequiredContent from '../common/LocationRequiredContent';
import { doPRM, getMaxCardWidth, getCampusPrimary } from '../../util/general';

const ShuttleCard = ({ stopsData, savedStops, permission, gotoRoutesList, gotoSavedList, removeStop, closestStop }) => {
	let content;
	// no permission to get location
	if (permission !== 'authorized') {
		content = (<LocationRequiredContent />);
	} /*else if (stopID === -1 && (!stopData || !stopData[stopID] || !stopData[stopID].arrivals || stopData[stopID].arrivals.length === 0)) {
		content =  (
			<View style={[styles.shuttle_card_row_center, styles.shuttle_card_loader]}>
				<ActivityIndicator size="large" />
			</View>
		);
	} else if (stopID !== -1 && (!stopData || !stopData[stopID] || !stopData[stopID].arrivals || stopData[stopID].arrivals.length === 0)) {
		content = (
			<View style={[styles.shuttle_card_row_center, styles.shuttle_card_loader]}>
				<Text style={styles.fs18}>No Shuttles en Route</Text>
				<Text style={[styles.pt10, styles.fs12, styles.dgrey]}>We were unable to locate any nearby shuttles, please try again later.</Text>
			</View>
		);
	}*/
	else {
		content =  (
			<ShuttleOverviewList
				stopsData={stopsData}
				savedStops={savedStops}
			/>
		);
	}

	const extraActions = [
		{
			name: 'Remove stop',
			action: removeStop
		},
		{
			name: 'Manage stops',
			action: gotoSavedList
		},
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
						closest={row.id === closestStop.id}
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
		/>
	);
};

export default ShuttleCard;

// There's gotta be a better way to do this...find a way to get rid of magic numbers
const nextArrivals = ((2 * doPRM(36)) + 32) + doPRM(20); // Two rows + text
const cardHeader = 26; // font + padding
const cardBody = doPRM(83) + (2 * doPRM(20)) + doPRM(26) + 20; // top + margin + font + padding

const styles = StyleSheet.create({
	add_container: { width: getMaxCardWidth(), backgroundColor: '#F9F9F9', alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingTop: 8, paddingBottom: 4, borderTopWidth: 1, borderBottomWidth: 1, borderColor: '#DDD' },
	add_label: { fontSize: 20, color: getCampusPrimary(), fontWeight: '300' },
	shuttle_card_row_center: { alignItems: 'center', justifyContent: 'center', width: getMaxCardWidth() },
	shuttle_card_loader: { height: nextArrivals + cardHeader + cardBody },
	shuttlecard_loading_fail: { marginHorizontal: doPRM(16), marginTop: doPRM(40), marginBottom: doPRM(60) },
	fs18: { fontSize: doPRM(18) },
	pt10: { paddingTop: 10 },
	fs12: { fontSize: doPRM(12) },
	dgrey: { color: '#333' },
});
