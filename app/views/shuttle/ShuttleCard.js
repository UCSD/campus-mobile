import React from 'react';
import {
	View,
	ActivityIndicator,
	StyleSheet
} from 'react-native';

import Card from '../card/Card';
import ShuttleOverview from './ShuttleOverview';
import LocationRequiredContent from '../common/LocationRequiredContent';
import { getPRM, getMaxCardWidth, round } from '../../util/general';
import logger from '../../util/logger';

const ShuttleCard = ({ stopData, permission, gotoShuttleStop, stopID }) => {
	let content;
	// no permission to get location
	if (permission !== 'authorized') {
		content = (<LocationRequiredContent />);
	} else if (stopID === -1) {
		content =  (
			<View style={[styles.shuttle_card_row_center, styles.shuttle_card_loader]}>
				<ActivityIndicator size="large" />
			</View>
		);
	} else {
		content =  (
			<ShuttleOverview
				onPress={() => gotoShuttleStop(stopID)}
				stopData={stopData}
				stopID={stopID}
			/>);
	}

	return (
		<Card id="shuttle" title="Shuttle" cardRefresh={this.refresh} isRefreshing={false}>
			{content}
		</Card>
	);

	/*
	// both stops failed to load
	if (this.state.closestStop1LoadFailed && this.state.closestStop2LoadFailed) {
		return (
			<View style={styles.shuttlecard_loading_fail}>
				<Text style={styles.fs18}>No Shuttles en Route</Text>
				<Text style={[styles.pt10, styles.fs12, styles.dgrey]}>We were unable to locate any nearby shuttles, please try again later.</Text>
			</View>
		);
	}*/
};

export default ShuttleCard;

// There's gotta be a better way to do this...find a way to get rid of magic numbers
const nextArrivals = ((2 * round(36 * getPRM())) + 32) + round(20 * getPRM()); // Two rows + text
const cardHeader = 26; // font + padding
const cardBody = (round(83 * getPRM()) + (2 * round(20 * getPRM()))) + (round(26 * getPRM()) + 20); // top + margin + font + padding

const styles = StyleSheet.create({
	shuttle_card_row_center: { alignItems: 'center', justifyContent: 'center', width: getMaxCardWidth(), overflow: 'hidden' },
	shuttle_card_loader: { height: nextArrivals + cardHeader + cardBody },
	shuttlecard_loading_fail: { marginHorizontal: round(16 * getPRM()), marginTop: round(40 * getPRM()), marginBottom: round(60 * getPRM()) },
	fs18: { fontSize: round(18 * getPRM()) },
	pt10: { paddingTop: 10 },
	fs12: { fontSize: round(12 * getPRM()) },
	dgrey: { color: '#333' },
});
