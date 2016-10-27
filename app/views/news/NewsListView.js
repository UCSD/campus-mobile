import React from 'react';
import {
	View,
	ListView,
	ActivityIndicator,
	InteractionManager,
} from 'react-native';

import NewsItemCard from './NewsItemCard';

const css = require('../../styles/css');

export default class NewsListView extends React.Component {

	constructor(props) {
		super(props);
		this.state = { loaded: false };
		this.datasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
	}

	componentDidMount() {
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
		const eventData = this.props.route.data;
		const eventDatasource = this.datasource.cloneWithRows(eventData);

		return (
			<View style={css.main_container}>
				<ListView
					style={css.welcome_listview}
					dataSource={eventDatasource}
					renderRow={(row) => <NewsItemCard data={row} navigator={this.props.navigator} />}
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
