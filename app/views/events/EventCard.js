'use strict'

import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';

import EventService from '../../services/eventService'
import Card from '../card/Card'
import CardComponent from '../card/CardComponent'
import EventList from './EventList'

var css = require('../../styles/css');
var logger = require('../../util/logger');

export default class EventCard extends CardComponent {

  constructor(props) {
		super(props);

		this.fetchEventsErrorInterval =  15 * 1000;			// Retry every 15 seconds
		this.fetchEventsErrorLimit = 3;
		this.fetchEventsErrorCounter = 0;

		this.state = {
			eventsData: [],
			eventsRenderAllRows: false,
			eventsDataLoaded: false,
			fetchEventsErrorLimitReached: false,
			eventsDefaultResults: 5
		}
  }

	componentDidMount() {
		this.refresh();
	}

	refresh() {
		EventService.FetchEvents()
		.then((responseData) => {
			this.setState({
				eventsData: responseData,
				eventsDataLoaded: true
			});
		})
		.catch((error) => {
			logger.error(error);
			if (this.fetchEventsErrorLimit > this.fetchEventsErrorCounter) {
				this.fetchEventsErrorCounter++;
				logger.log('ERR: fetchEvents1: refreshing again in ' + this.fetchEventsErrorInterval/1000 + ' sec');
				this.refreshEventsTimer = setTimeout( () => { this.refresh() }, this.fetchEventsErrorInterval);
			} else {
				logger.log('ERR: fetchEvents2: Limit exceeded - max limit:' + this.fetchEventsErrorLimit);
				this.setState({ fetchEventsErrorLimitReached: true });
			}
		})
		.done();
	}

  render() {
	return (
		<Card id='events' title='Events'>
			<View style={css.events_list}>
				{this.state.eventsDataLoaded ? (
					<EventList data={this.state.eventsData} navigator={this.props.navigator} />
				) : null}

				{this.state.fetchEventsErrorLimitReached ? (
					<View style={[css.flexcenter, css.pad40]}>
						<Text>There was a problem loading events, try back soon.</Text>
					</View>
				) : null }
			</View>
		</Card>
	  );
	}
  }
