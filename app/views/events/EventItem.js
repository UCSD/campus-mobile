'use strict'

import React from 'react'
import {
	StyleSheet,
	View,
	Text,
	Navigator,
	TouchableHighlight,
	Image,
} from 'react-native';

import EventDetail from './EventDetail'
var css = require('../../styles/css');

export default class EventItem extends React.Component {

	gotoEventDetail(eventData) {
		this.props.navigator.push({ component: EventDetail, title: 'Events', eventData: eventData });
	}

	render() {
		var data = this.props.data;
		var eventTitleStr = data.EventTitle.replace('&amp;','&');
		var eventDescriptionStr = data.EventDescription.replace('&amp;','&').replace(/\n.*/g,'').trim();

		if (eventDescriptionStr.length > 0) {
			if (eventTitleStr.length < 25) {
				eventDescriptionStr = eventDescriptionStr.substring(0,56) + '...';
			} else if (eventTitleStr.length < 50) {
				eventDescriptionStr = eventDescriptionStr.substring(0,28) + '...';
			} else {
				eventDescriptionStr = '';
			}
		}

		var eventDateDay;
		if (data.EventDate) {
			var eventDateDayArray = data.EventDate[0].split(', ');
			eventDateDay = eventDateDayArray[1] + ', ' + eventDateDayArray[2].substring(5,22).toLowerCase();
		} else {
			eventDateDay = 'Ongoing Event';
		}

		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoEventDetail(data) }>
				<View style={css.events_list_row}>
					<View style={css.events_list_left_container}>
						<Text style={css.events_list_title}>{eventTitleStr}</Text>
						{eventDescriptionStr ? (<Text style={css.events_list_desc}>{eventDescriptionStr}</Text>) : null }
						<Text style={css.events_list_postdate}>{eventDateDay}</Text>
					</View>

					<Image style={css.events_list_image} source={{ uri: data.EventImage }} />
				</View>
			</TouchableHighlight>
		)
	}
}
