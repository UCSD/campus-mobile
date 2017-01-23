import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import EventDetail from './EventDetail';
import { Actions } from 'react-native-router-flux';

const css = require('../../styles/css');
const general = require('../../util/general');
const moment = require('moment');

export default class EventItem extends React.Component {

	render() {
		const data = this.props.data;
		let eventTitleStr = data.title;// EventTitle.replace('&amp;','&');
		eventTitleStr = eventTitleStr.trim();
		const eventDescriptionStr = data.description;// EventDescription.replace('&amp;','&').replace(/\n.*/g,'').trim();
		let eventDescriptionStrTrimmed;
		if (eventDescriptionStr) {
			eventDescriptionStrTrimmed = eventDescriptionStr.substring(0,150);
			if (eventDescriptionStr.length > 150) {
				eventDescriptionStrTrimmed += '...';
			}
		}

		const eventDateDay = moment(data.eventdate).format("MMM Do") + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime);

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoEventDetail(data)}>
				<View style={css.card_main}>
					<View style={css.events_card_title_container}>
						<Text style={css.events_card_title}>{eventTitleStr}</Text>
					</View>
					<View style={css.events_card_container}>
						<View style={css.events_card_left_container}>
							{eventDescriptionStr ? (<Text style={css.events_card_desc}>{eventDescriptionStrTrimmed}</Text>) : null }
							<Text style={css.events_card_postdate}>{eventDateDay}</Text>
						</View>
						<Image style={css.events_card_image} source={{ uri: data.imagethumb }} />
					</View>
				</View>
			</TouchableHighlight>
		);
	}

	gotoEventDetail(eventData) {
		Actions.EventDetail({ eventData });
	}
}
