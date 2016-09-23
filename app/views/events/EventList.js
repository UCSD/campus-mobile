'use strict';

import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import EventItem from './EventItem';
import EventListView from './EventListView';

var css = require('../../styles/css');

export default class EventList extends React.Component {

	constructor(props){
		super(props);
		this.state = {
			eventsRenderAllRows: false
		}
		this.datasource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
	}

	render() {
		var eventData = [];
		if (this.state.eventsRenderAllRows) {
			eventData = this.props.data;
		} else {
			eventData = this.props.data.slice(0, 3);
		}

		var eventDatasource = this.datasource.cloneWithRows(eventData);

		return (
			<View>
				<ListView
					dataSource={eventDatasource}
					renderRow={ (row) => <EventItem data={row} navigator={this.props.navigator} /> }
				/>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoEventListView() }>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View All Events</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}

	gotoEventListView() {
		this.props.navigator.push({ id: 'EventListView', title: 'Events', name: 'Events', component: EventListView, data: this.props.data });
	}
}