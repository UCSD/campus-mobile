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

var css = require('../../styles/css');

export default class EventCard extends React.Component {

  constructor(props) {
    super(props);

    this.fetchEventsErrorInterval =  15 * 1000;			// Retry every 15 seconds
  	this.fetchEventsErrorLimit = 3;
  	this.fetchEventsErrorCounter = 0;

    this.state = {
      eventsDataFull: [],
      eventsDataPartial: [],
      eventsRenderAllRows: false,
      fetchEventsErrorLimitReached: false
    }
  }

  refresh() {
    EventService.FetchEvents
			.then((responseData) => {

				var responseDataFull = responseData;
				var responseDataPartial = responseData.slice(0, this.eventsDefaultResults);

				var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
				var dsPartial = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

				this.setState({
					eventsDataFull: dsFull.cloneWithRows(responseDataFull),
					eventsDataPartial: dsPartial.cloneWithRows(responseDataPartial),
					eventsDataLoaded: true
				});
			})
			.catch((error) => {
				if (this.fetchEventsErrorLimit > this.fetchEventsErrorCounter) {
					this.fetchEventsErrorCounter++;
					logger.custom('ERR: fetchEvents1: refreshing again in ' + this.fetchEventsErrorInterval/1000 + ' sec');
					this.refreshEventsTimer = this.setTimeout( () => { this.refresh() }, this.fetchEventsErrorInterval);
				} else {
					logger.custom('ERR: fetchEvents2: Limit exceeded - max limit:' + this.fetchEventsErrorLimit);
					this.setState({ fetchEventsErrorLimitReached: true });
				}
			})
			.done();
	}

  render() {
    var eventsList = [];
    if (this.state.eventsRenderAllRows){
      eventsList = this.state.eventsDataFull;
    } else {
      eventsList = this.state.eventsDataPartial;
    }

    return (
      <Card title='Campus Events'>
        <View style={css.events_list}>
          <ListView
            dataSource={eventsList}
            renderRow={ (row) => <EventItem data={row} /> }
            style={css.wf_listview} />

          {this.state.eventsRenderAllRows === false ? (
            <TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this._setState('eventsRenderAllRows', true) }>
              <View style={css.events_more}>
                <Text style={css.events_more_label}>Show More Events &#9660;</Text>
              </View>
            </TouchableHighlight>
          ) : null }

          {this.state.eventsRenderAllRows === true ? (
            <TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this._setState('eventsRenderAllRows', false) }>
              <View style={css.events_more}>
                <Text style={css.events_more_label}>Show Less Events &#9650;</Text>
              </View>
            </TouchableHighlight>
          ) : null }

          {this.state.fetchEventsErrorLimitReached ? (
            <View style={[css.flexcenter, css.pad40]}>
              <Text>There was a problem loading Student Events</Text>
            </View>
          ) : null }
					</View>
        </Card>
      );
    }
  }
