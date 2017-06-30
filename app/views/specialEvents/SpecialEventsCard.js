import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import BannerCard from '../common/BannerCard';
import SpecialEventsListView from './SpecialEventsListView';
import Touchable from '../common/Touchable';
import {
	COLOR_DGREY,
	COLOR_PRIMARY,
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';

const SpecialEventsCard = ({ specialEvents, saved, hideCard }) => (
	<View>
		{ (Array.isArray(saved) && saved.length < 1) ?
			(
				<BannerCard
					image={specialEvents.logo}
					onPress={() => Actions.SpecialEventsView()}
					onClose={() => hideCard('specialEvents')}
				/>
			) :
			(
				<Card
					title={specialEvents.name}
					header={specialEvents['logo-sm']}
					id="specialEvents"
				>
					<View
						style={styles.contentContainer}
					>
						<SpecialEventsListView
							scrollEnabled={false}
							personal={true}
							rows={4}
							disabled={true}
							style={styles.specialEventsListView}
						/>
						<Touchable
							onPress={() => Actions.SpecialEventsView()}
						>
							<View style={styles.more}>
								<Text style={styles.more_label}>
									See Full Schedule
								</Text>
							</View>
						</Touchable>
					</View>
				</Card>
			)
		}
	</View>
);

const styles = StyleSheet.create({
	more: { alignItems: 'center', justifyContent: 'center', padding: 6 },
	more_label: { fontSize: 20, color: COLOR_PRIMARY, fontWeight: '300' },
	specialEventsListView: { borderBottomWidth: 1, borderBottomColor: COLOR_DGREY },
	contentContainer: { flex: 1, width: MAX_CARD_WIDTH },
});

export default SpecialEventsCard;
