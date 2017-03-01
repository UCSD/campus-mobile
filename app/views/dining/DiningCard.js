import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	ActivityIndicator,
	StyleSheet
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import DiningList from './DiningList';
import LocationRequiredContent from '../common/LocationRequiredContent';
import { getMaxCardWidth } from '../../util/general';

const css = require('../../styles/css');

const DiningCard = ({ data, rows, permission }) => {
	let content;
	// no permission to get location
	if (permission !== 'authorized') {
		content = (<LocationRequiredContent />);
	} else if (data === null || data.length === 0) {
		content =  (
			<View style={[styles.card_row_center, styles.card_loader]}>
				<ActivityIndicator size="large" />
			</View>
		);
	} else {
		content = (
			<View style={css.dining_card}>
				<View style={css.dc_locations}>
					<DiningList data={data} rows={rows} />
				</View>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.DiningListView({ data })}>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View All Locations</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}

	return (
		<Card id="dining" title="Dining">
			{content}
		</Card>
	);
};

const styles = StyleSheet.create({
	card_row_center: { alignItems: 'center', justifyContent: 'center', width: getMaxCardWidth(), overflow: 'hidden' },
	card_loader: { height: 100 },
});

export default DiningCard;
