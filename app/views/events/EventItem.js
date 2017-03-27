import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import { Actions } from 'react-native-router-flux';

const css = require('../../styles/css');
const general = require('../../util/general');
const moment = require('moment');

const EventItem = ({ data }) => (
	<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.EventDetail({ data })}>
		<View style={css.events_list_row}>
			<Text
				style={css.events_list_title}
				numberOfLines={1}
			>
				{data.title}
			</Text>
			<View style={css.events_list_info}>
				<View style={css.events_list_info_left}>
					{data.description ? (
						<Text
							style={css.events_list_desc}
							numberOfLines={3}
						>
							{data.description}
						</Text>
					) : null }

					<Text style={css.events_list_postdate}>
						{moment(data.eventdate).format('MMM Do') + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime)}
					</Text>
				</View>
				<Image style={css.events_list_image} source={{ uri: data.imagethumb }} />
			</View>
		</View>
	</TouchableHighlight>
);

export default EventItem;
