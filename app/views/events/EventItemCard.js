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
import Card from '../card/Card'

var css = require('../../styles/css');

export default class EventItem extends React.Component {

	gotoEventDetail(eventData) {
		this.props.navigator.push({ id: 'EventDetail', name: 'EventDetail', title: 'Events', component: EventDetail, eventData: eventData });
	}

	render() {
		var data = this.props.data;
		var eventTitleStr = data.EventTitle.replace('&amp;','&');
		eventTitleStr = eventTitleStr.trim();
		var eventDescriptionStr = data.EventDescription.replace('&amp;','&').replace(/\n.*/g,'').trim();

		var eventDescriptionStrTrimmed = eventDescriptionStr.substring(0,150);
		if(eventDescriptionStr.length > 150) {
			eventDescriptionStrTrimmed += '...';
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
				<View style={css.card_main}>
					<View style={css.events_card_title_container}>
						<Text style={css.events_card_title}>{eventTitleStr}</Text>
					</View>
					<View style={css.events_card_container}>
						<View style={css.events_card_left_container}>
							{eventDescriptionStr ? (<Text style={css.events_card_desc}>{eventDescriptionStrTrimmed}</Text>) : null }
							<Text style={css.events_card_postdate}>{eventDateDay}</Text>
						</View>
						<Image style={css.events_card_image} source={{ uri: data.EventImage }} />
					</View>
				</View>
			</TouchableHighlight>
		)
	}
}
