import React from 'react';
import {
	View,
	Text
} from 'react-native';

import Card from '../card/Card';
import BannerCard from '../common/BannerCard';

const toggle = true;

const ConferenceCard = () => (
	<View>
		{ toggle ?
			(
				<BannerCard
					image={'https://thumbs.dreamstime.com/z/computer-banner-680247.jpg'}
					onPress={() => console.log('banner pressed')}
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
