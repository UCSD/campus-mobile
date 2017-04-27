import React from 'react';
import {
	View,
	Text,
	TouchableOpacity
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import BannerCard from '../common/BannerCard';
import ConferenceListView from './ConferenceListView';
import { getMaxCardWidth } from '../../util/general';

const toggle = false;

const ConferenceCard = ({ schedule, saved }) => (
	<View>
		{ (saved.length < 1) ?
			(
				<BannerCard
					image={'https://thumbs.dreamstime.com/z/computer-banner-680247.jpg'}
					onPress={() => Actions.ConferenceBar()}
				/>
			) :
			(
				<Card
					title="Conference"
					header={'http://ucsdnews.ucsd.edu/news_uploads/2017_04_21_vinetz_teaser.jpg'}
				>
					<View
						style={{ flex: 1, width: getMaxCardWidth() }}
					>
						<ConferenceListView
							scrollEnabled={false}
							personal={true}
							rows={4}
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

export default ConferenceCard;
