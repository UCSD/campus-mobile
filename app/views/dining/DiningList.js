import React from 'react';
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';

import DiningItem from './DiningItem';

const css = require('../../styles/css');

export default class DiningList extends React.Component {

	constructor(props) {
		super(props);
		this.datasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
	}

	render() {
		let diningData = [];

		if (this.props.limitResults) {
			diningData = this.props.data.slice(0, this.props.limitResults);
		} else {
			diningData = this.props.data;
		}
		
		const diningDatasource = this.datasource.cloneWithRows(diningData);

		return (
			<ListView dataSource={diningDatasource} renderRow={
				(row) => <DiningItem data={row} navigator={this.props.navigator} />
			}/>
		);
	}
}