import React from 'react';
import {
	View,
	ListView,
} from 'react-native';

import QuicklinksItem from './QuicklinksItem';

const css = require('../../styles/css');
const logger = require('../../util/logger');

export default class QuicklinksListView extends React.Component {

	constructor(props) {
		super(props);
		this.state = { loaded: false };
		this.datasource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });
	}

	componentDidMount() {
		logger.ga('View Loaded: Quicklinks List View');
	}

	render() {
		const quicklinksData = this.props.data;
		const quicklinksDatasource = this.datasource.cloneWithRows(quicklinksData);

		return (
			<View style={css.view_all_container}>
				<ListView style={css.dining_listview} dataSource={quicklinksDatasource} renderRow={
					(row) => <QuicklinksItem data={row} navigator={this.props.navigator} />
				}/>
			</View>
		);
	}
}