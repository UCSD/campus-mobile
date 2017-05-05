import React from 'react';
import {
	View,
	Text,
	TouchableOpacity,
	StyleSheet,
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import BannerCard from '../common/BannerCard';
import ConferenceListView from './ConferenceListView';
import { getMaxCardWidth } from '../../util/general';

const ConferenceCard = ({ conference, saved }) => (
	<View>
		{ (saved.length < 1) ?
			(
				<BannerCard
					image={conference['conference-logo-lg']}
					onPress={() => Actions.ConferenceBar()}
				/>
			) :
			(
				<Card
					title={conference.name}
					header={conference['conference-logo-lg']}
				>
					<View
						style={{ flex: 1, width: getMaxCardWidth() }}
					>
						<ConferenceListView
							scrollEnabled={false}
							personal={true}
							rows={4}
							disabled={true}
						/>
						<TouchableOpacity
							onPress={() => Actions.ConferenceBar()}
						>
							<Text>
								View Full Schedule
							</Text>
						</TouchableOpacity>
					</View>
				</Card>
			)
		}
	</View>
);

const styles = StyleSheet.create({
	promoCardContainer: { height: ((getMaxCardWidth() / 800) * 200), width: getMaxCardWidth(), borderWidth: 2 },
	bannerCardContainer: { padding: 8 },
});

export default ConferenceCard;
