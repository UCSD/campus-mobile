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
import { getMaxCardWidth, getCampusPrimary } from '../../util/general';
import Touchable from '../common/Touchable';
import {
	COLOR_DGREY
} from '../../styles/ColorConstants';

const ConferenceCard = ({ conference, saved, hideCard }) => (
	<View>
		{ (saved.length < 1) ?
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
					header={conference.logo}
					id="conference"
				>
					<View
						style={{ flex: 1, width: getMaxCardWidth() }}
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
	more_label: { fontSize: 20, color: getCampusPrimary(), fontWeight: '300' },
	conferenceListView: { borderBottomWidth: 1, borderBottomColor: COLOR_DGREY },
});

export default ConferenceCard;
