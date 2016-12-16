import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import EventDetail from './EventDetail';

const css = require('../../styles/css');
const general = require('../../util/general');
const moment = require('moment');

export default class EventItem extends React.Component {

	gotoEventDetail(eventData) {
		this.props.navigator.push({ id: 'EventDetail', name: 'EventDetail', title: 'Events', component: EventDetail, eventData });
	}

	render() {
		const data = this.props.data;
		const eventTitleStr = data.title;// data.EventTitle.replace('&amp;','&');
		let eventDescriptionStr = data.description;// data.EventDescription.replace('&amp;','&').replace(/\n.*/g,'').trim();

		if (eventDescriptionStr.length > 0) {
			if (eventTitleStr.length < 25) {
				eventDescriptionStr = eventDescriptionStr.substring(0,56) + '...';
			} else if (eventTitleStr.length < 50) {
				eventDescriptionStr = eventDescriptionStr.substring(0,28) + '...';
			} else {
				eventDescriptionStr = '';
			}
		}

		const eventDateDay = moment(data.eventdate).format("MMM Do") + ', ' + general.militaryToAMPM(data.starttime) + ' - ' + general.militaryToAMPM(data.endtime);

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoEventDetail(data)}>
				<View style={css.events_list_row}>
					<View style={css.events_list_left_container}>
						<Text style={css.events_list_title}>{eventTitleStr}</Text>
						{eventDescriptionStr ? (<Text style={css.events_list_desc}>{eventDescriptionStr}</Text>) : null }
						<Text style={css.events_list_postdate}>{eventDateDay}</Text>
					</View>

					<Image style={css.events_list_image} source={{ uri: data.imagethumb }} />
				</View>
			</TouchableHighlight>
		);
	}
}
