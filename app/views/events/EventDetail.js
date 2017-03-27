import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	Linking,
	TouchableHighlight,
	Dimensions
} from 'react-native';

import moment from 'moment';

import SafeImage from '../common/SafeImage';
import css from '../../styles/css';
import logger from '../../util/logger';
import general from '../../util/general';

const EventDetail = ({ data }) => {
	logger.ga('View Loaded: Event Detail: ' + data.title);

	return (
		<View style={[css.main_container, css.whitebg]}>
			<ScrollView>

				{data.imagehq ? (
					<SafeImage
						source={{ uri: data.imagehq }}
						style={{
							width: Dimensions.get('window').width,
							height: 200
						}}
						resizeMode={'contain'}
					/>
				) : null }

				<View style={css.news_detail_container}>
					<View style={css.eventdetail_top_right_container}>
						<Text style={css.eventdetail_eventname}>
							{data.title}
						</Text>
						<Text style={css.eventdetail_eventlocation}>
							{data.location}
						</Text>
						<Text style={css.eventdetail_eventdate}>
							{moment(data.eventdate).format('MMM Do') + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime)}
						</Text>
					</View>

					<Text style={css.eventdetail_eventdescription}>
						{data.description}
					</Text>

					{data.contact_info ? (
						<TouchableHighlight
							underlayColor={'rgba(200,200,200,.1)'}
							onPress={() => Linking.openURL('mailto:' + data.contact_info + '?')}
						>
							<View style={css.eventdetail_readmore_container}>
								<Text style={css.eventdetail_readmore_text}>
									Email: {data.contact_info}
								</Text>
							</View>
						</TouchableHighlight>
					) : null }

				</View>
			</ScrollView>
		</View>
	);
};

export default EventDetail;
