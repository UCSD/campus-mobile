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
	COLOR_MGREY,
	COLOR_PRIMARY,
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';

export const SpecialEventsCard = ({ specialEvents, saved, hideCard }) => (
	<View>
		{ (Array.isArray(saved) && saved.length < 1) ?
			(
				<BannerCard
					title={specialEvents.name}
					image={specialEvents.logo}
					onPress={() => Actions.SpecialEventsView({ personal: false })}
					onClose={() => hideCard('specialEvents')}
				/>
			) :
			(
				<Card
					title={specialEvents.name}
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
							inCard={true}
						/>
						<Touchable
							onPress={() => Actions.SpecialEventsView({ personal: true })}
						>
							<View style={styles.more}>
								<Text style={styles.more_label}>
									See My Schedule
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
	specialEventsListView: { borderBottomWidth: 1, borderBottomColor: COLOR_MGREY },
	contentContainer: { flexGrow: 1, width: MAX_CARD_WIDTH },
});

export default SpecialEventsCard;
