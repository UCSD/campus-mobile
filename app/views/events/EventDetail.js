import React from 'react';
import {
	View,
	Text,
	ScrollView,
	Image,
	Linking,
	TouchableHighlight,
} from 'react-native';

import moment from 'moment';

import css from '../../styles/css';
import logger from '../../util/logger';
import general from '../../util/general';

const EventDetail = ({ data }) => {
	logger.ga('View Loaded: Event Detail: ' + data.title);

	return (
		<View style={[css.main_container, css.whitebg]}>
			<ScrollView contentContainerStyle={css.scroll_default}>

				{data.imagehq ? (
					<Image
						style={{ flex:1 }}
						source={{ uri: data.imagehq }}
						resizeMode={Image.resizeMode.contain}
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
