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
		<View style={css.card_main}>
			<View style={css.events_card_title_container}>
				<Text style={css.events_card_title}>{data.title}</Text>
			</View>
			<View style={css.events_card_container}>
				<View style={css.events_card_left_container}>
					{data.description ? (<Text style={css.events_card_desc} numberOfLines={3}>{data.description}</Text>) : null }
					<Text style={css.events_card_postdate}>{moment(data.eventdate).format('MMM Do') + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime)}</Text>
				</View>
				<Image style={css.events_card_image} source={{ uri: data.imagethumb }} />
			</View>
		</View>
	</TouchableHighlight>
);

export default EventItem;
