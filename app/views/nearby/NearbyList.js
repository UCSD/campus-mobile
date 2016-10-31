import React from 'react';
import {
	View,
	ListView,
} from 'react-native';

import NearbyItem from './NearbyItem';

const css = require('../../styles/css');

let nearbyCounter;

export default class NearbyList extends React.Component {
	_renderRow = (row, sectionID, rowID) =>
		<NearbyItem data={row} navigator={this.props.navigator} color={this.props.colors[nearbyCounter++]} />

	render() {
		nearbyCounter = 0;

		return (
			<View>
				<ListView
					dataSource={this.props.data}
					renderRow={this._renderRow}
					style={css.flex}
				/>
			</View>
		);
	}
}
