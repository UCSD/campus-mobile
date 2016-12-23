import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	Image,
} from 'react-native';

import DiningDetail from './DiningDetail';
import Icon from 'react-native-vector-icons/Ionicons';
import { Actions } from 'react-native-router-flux';

const css = require('../../styles/css');
const general = require('../../util/general');

export default class DiningItem extends React.Component {

	render() {
		const data = this.props.data;
		
		var currentTimestamp = general.getTimestamp('yyyy-mm-dd');
		var dayOfWeek = general.getTimestamp('ddd').toLowerCase();

		return (
			<View style={css.dc_locations_row}>
				<TouchableHighlight style={css.dc_locations_row_left} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => this.gotoDiningDetail(data) }>
					<View>
						<Text style={css.dc_locations_title}>{data.name}</Text>
						<Text style={css.dc_locations_hours}>{data.regularHours}</Text>
						{data.specialHours ? (
							<Text style={css.dc_locations_spec_hours}>Special Hours:{"\n"}{data.specialHours}</Text>
						) : null }
					</View>
				</TouchableHighlight>

				{data.coords.lat != 0 ? (
					<TouchableHighlight style={css.dc_locations_row_right} underlayColor={'rgba(200,200,200,.1)'} onPress={ () => general.gotoNavigationApp('walk', data.coords.lat, data.coords.lon) }>
						<View style={css.dl_dir_traveltype_container}>
							<Icon name='md-walk' size={32} color='#182B49' />
							{data.distanceMilesStr ? (
								<Text style={css.dl_dir_eta}>{data.distanceMilesStr}</Text>
							) : null }
						</View>
					</TouchableHighlight>
				) : null }
			</View>
		);
	}

	gotoDiningDetail(diningData) {
		Actions.DiningDetail({ data: diningData });
	}
}