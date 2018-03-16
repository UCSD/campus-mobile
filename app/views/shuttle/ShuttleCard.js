import React from 'react';
import {
	StyleSheet,
	Text,
	TouchableHighlight
} from 'react-native';
import { withNavigation } from 'react-navigation';

import ShuttleOverview from './ShuttleOverview';
import ScrollCard from '../card/ScrollCard';
import Touchable from '../common/Touchable'
import {
	COLOR_PRIMARY,
	COLOR_MGREY,
	COLOR_LGREY
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';

const ShuttleCard = ({ navigation, stopsData, savedStops, gotoRoutesList, gotoSavedList, updateScroll, lastScroll }) => {
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
				row => (
					<ShuttleOverview
						onPress={() => navigation.navigate('ShuttleStop', { stopID: row.id })}
						stopData={stopsData[row.id]}
						closest={Object.prototype.hasOwnProperty.call(row, 'savedIndex')}
					/>
				)
			}
			actionButton={
				<Touchable
					style={styles.addButton}
					onPress={() => gotoRoutesList()}
				>
					<Text style={styles.addText}>Add a Stop</Text>
				</Touchable>
			}
			extraActions={extraActions}
			updateScroll={updateScroll}
			lastScroll={lastScroll}
		/>
	);
};

export default withNavigation(ShuttleCard);

const styles = StyleSheet.create({
	addButton: { width: MAX_CARD_WIDTH, backgroundColor: COLOR_LGREY, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4, paddingVertical: 8, borderTopWidth: 1, borderBottomWidth: 1, borderColor: COLOR_MGREY },
	addText: { fontSize: 20, color: COLOR_PRIMARY, fontWeight: '300' },
});
