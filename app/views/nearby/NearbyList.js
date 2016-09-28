import React from 'react'
import {
	View,
	ListView,
	Text,
	TouchableHighlight,
} from 'react-native';
import NearbyItem from './NearbyItem';

var css = require('../../styles/css');
var logger = require('../../util/logger');

var nearbyCounter;

export default class NearbyList extends React.Component {
	constructor(props){
		super(props);
	}

	componentDidMount() {
		
	}

	_renderRow = (row, sectionID, rowID) => {
		return (
			<NearbyItem data={row} navigator={this.props.navigator} color={this.props.colors[nearbyCounter++]}/>
		);
	}

	render() {
		nearbyCounter = 0;

		return (
			<View>
				<ListView 
					dataSource={this.props.data} 
					renderRow={this._renderRow} 
					style={css.flex} />
			</View>
		);
	}
}
