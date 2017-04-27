import React from 'react';
import {
	View,
	Text
} from 'react-native';
import { Actions } from 'react-native-router-flux';

import Card from '../card/Card';
import BannerCard from '../common/BannerCard';

const toggle = true;

const ConferenceCard = ({ schedule }) => (
	<View>
		{ toggle ?
			(
				<BannerCard
					image={'https://thumbs.dreamstime.com/z/computer-banner-680247.jpg'}
					onPress={() => Actions.ConferenceBar({ schedule })}
				/>
			) :
			(
				<Card
					title="Conference"
					header={'http://ucsdnews.ucsd.edu/news_uploads/2017_04_21_vinetz_teaser.jpg'}
				>
					<Text>
						Hello
					</Text>
				</Card>
			)
		}
	</View>
);

export default ConferenceCard;
