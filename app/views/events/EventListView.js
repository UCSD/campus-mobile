import React from 'react';
import {
	View,
	ListView,
	ActivityIndicator,
	InteractionManager,
} from 'react-native';

import EventItemCard from './EventItemCard';

const css = require('../../styles/css');
const logger = require('../../util/logger');

export default class EventListView extends React.Component {

	constructor(props) {
		super(props);
		this.state = { loaded: false };
		this.datasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
	}

	componentDidMount() {
		logger.ga('View Loaded: EventList');

		InteractionManager.runAfterInteractions(() => {
			this.setState({ loaded: true });
		});
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
		const eventData = this.props.data;
		const eventDatasource = this.datasource.cloneWithRows(eventData);

		return (
			<View style={css.main_container}>
				<ListView
					style={css.welcome_listview}
					dataSource={eventDatasource}
					renderRow={(row) => <EventItemCard data={row} navigator={this.props.navigator} />}
				/>
			</View>
		);
	}

	render() {
		if (!this.state.loaded) {
			return this.renderLoadingView();
		}
		return this.renderListView();
	}

}
