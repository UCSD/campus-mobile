'use strict'

import React from 'react'
import {
	View,
  ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import EventService from '../../services/eventService'
import EventItem from './EventItem'
import Card from '../card/Card'

var css = require('../../styles/css');
var logger = 			require('../../util/logger');

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
			eventsDataLoaded: false,
      fetchEventsErrorLimitReached: false
    }
  }

	componentDidMount() {
		this.refresh();
	}

  refresh() {
		var that = this;
    EventService.FetchEvents()
			.then((responseData) => {

				var responseDataFull = responseData;
				var responseDataPartial = responseData.slice(0, this.eventsDefaultResults);

				var dsFull = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
				var dsPartial = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

				that.setState({
					eventsDataFull: dsFull.cloneWithRows(responseDataFull),
					eventsDataPartial: dsPartial.cloneWithRows(responseDataPartial),
					eventsDataLoaded: true
				});
			})
			.catch((error) => {
				logger.error(error);
				if (that.fetchEventsErrorLimit > that.fetchEventsErrorCounter) {
					that.fetchEventsErrorCounter++;
					logger.custom('ERR: fetchEvents1: refreshing again in ' + that.fetchEventsErrorInterval/1000 + ' sec');
					that.refreshEventsTimer = setTimeout( () => { that.refresh() }, that.fetchEventsErrorInterval);
				} else {
					logger.custom('ERR: fetchEvents2: Limit exceeded - max limit:' + that.fetchEventsErrorLimit);
					that.setState({ fetchEventsErrorLimitReached: true });
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
        <View style={css.events_list}>
					{this.state.eventsDataLoaded ? (
						<ListView
							dataSource={eventsList}
							renderRow={ (row) => <EventItem data={row} /> }
							style={css.wf_listview} />

					) : null}

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
      );
    }
  }
