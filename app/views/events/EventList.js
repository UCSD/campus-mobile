import React from 'react';
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import EventItem from './EventItem';
import EventListView from './EventListView';
import { Actions } from 'react-native-router-flux';

const css = require('../../styles/css');

export default class EventList extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			eventsRenderAllRows: false
		};
		this.datasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
	}

	gotoEventListView() {
		Actions.EventListView({ data: this.props.data });
	}

	render() {
		let eventData = [];
		if (this.state.eventsRenderAllRows) {
			eventData = this.props.data;
		} else {
			eventData = this.props.data.slice(0, 3);
		}

		const eventDatasource = this.datasource.cloneWithRows(eventData);

		return (
			<View>
				<ListView
					dataSource={eventDatasource}
					renderRow={(row) => <EventItem data={row} navigator={this.props.navigator} />}
				/>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.gotoEventListView()}>
					<View style={css.events_more}>
						<Text style={css.events_more_label}>View All Events</Text>
					</View>
				</TouchableHighlight>
			</View>
		);
	}
}
