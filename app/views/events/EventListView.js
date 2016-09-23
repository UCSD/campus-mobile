'use strict';

import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
	ActivityIndicator,
	InteractionManager,
} from 'react-native';
import EventItem from './EventItem';
import EventItemCard from './EventItemCard';

var css = require('../../styles/css');

export default class EventListView extends React.Component {

	constructor(props){
		super(props);
		this.state = {loaded: false};
		this.datasource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
	}

	componentDidMount() {
		InteractionManager.runAfterInteractions(() => {
			this.setState({loaded: true})
		});
	}

	render() {
		if (!this.state.loaded) {
			return this.renderLoadingView();
		}
		return this.renderListView();
	}

	renderLoadingView() {
		return (
			<View style={css.main_container}>
				<ActivityIndicator
					animating={this.state.animating}
					style={css.welcome_ai}
					size="large"
				/>
			</View>
		);
	}

	renderListView() {
		var eventData = this.props.route.data;
		var eventDatasource = this.datasource.cloneWithRows(eventData);

		return (
			<View style={css.main_container}>
				<ListView
					style={css.welcome_listview}
					dataSource={eventDatasource}
					renderRow={ (row) => <EventItemCard data={row} navigator={this.props.navigator} /> }
				/>
			</View>
		);
	}
}