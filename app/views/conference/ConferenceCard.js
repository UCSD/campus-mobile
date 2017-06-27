import React from 'react';
import {
	View,
	Text,
	StyleSheet,
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import BannerCard from '../common/BannerCard';
import ConferenceListView from './ConferenceListView';
import Touchable from '../common/Touchable';
import {
	COLOR_DGREY,
	COLOR_PRIMARY,
} from '../../styles/ColorConstants';
import {
	MAX_CARD_WIDTH,
} from '../../styles/LayoutConstants';

const ConferenceCard = ({ conference, saved, hideCard }) => (
	<View>
		{ (Array.isArray(saved) && saved.length < 1) ?
			(
				<BannerCard
					image={conference.logo}
					onPress={() => Actions.ConferenceView()}
					onClose={() => hideCard('conference')}
				/>
			) :
			(
				<Card
					title={conference.name}
					header={conference['logo-sm']}
					id="conference"
				>
					<View
						style={styles.contentContainer}
					>
						<ConferenceListView
							scrollEnabled={false}
							personal={true}
							rows={4}
							disabled={true}
							style={styles.conferenceListView}
						/>
						<Touchable
							onPress={() => Actions.ConferenceView()}
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
	conferenceListView: { borderBottomWidth: 1, borderBottomColor: COLOR_DGREY },
	contentContainer: { flex: 1, width: MAX_CARD_WIDTH },
});

export default ConferenceCard;
