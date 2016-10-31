import React from 'react';
import {
	View,
	ListView,
} from 'react-native';

import DiningItem from './DiningItem';

const css = require('../../styles/css');
const logger = require('../../util/logger');

export default class DiningListView extends React.Component {

	constructor(props) {
		super(props);
		this.state = { loaded: false };
		this.datasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
	}

	componentDidMount() {
		logger.ga('View Loaded: Dining List View');
	}

	render() {
		const diningData = this.props.route.data;
		const diningDatasource = this.datasource.cloneWithRows(diningData);

		return (
			<View style={css.view_all_container}>
				<ListView style={css.dining_listview} dataSource={diningDatasource} renderRow={
					(row) => <DiningItem data={row} navigator={this.props.navigator} />
				}/>
			</View>
		);
	}
}