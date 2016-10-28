import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

const css = require('../../styles/css');

// overview of a specific shuttle route
export default class ShuttleOverview extends React.Component {
	render() {
		if (!this.props.stopData) {
			return null;
		}
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this.props.onPress(this.props.stopData, this.props.shuttleData)}>
				<View style={css.shuttle_card_row}>
					<View style={css.shuttle_card_row_top}>
						<View style={css.shuttle_card_rt_1} />
						<View style={[css.shuttle_card_rt_2, { backgroundColor: this.props.stopData.routeColor, borderColor: this.props.stopData.routeColor }]}>
							<Text style={css.shuttle_card_rt_2_label}>{this.props.stopData.routeShortName}</Text>
						</View>
						<View style={css.shuttle_card_rt_3}>
							<Text style={css.shuttle_card_rt_3_label}>@</Text>
						</View>
						<View style={css.shuttle_card_rt_4}>
							<Text style={css.shuttle_card_rt_4_label} numberOfLines={3}>{this.props.stopData.stopName}</Text>
						</View>
						<View style={css.shuttle_card_rt_5} />
					</View>
					<View style={css.shuttle_card_row_bot}>
						<Text style={css.shuttle_card_row_arriving}>
							<Text style={css.grey}>Arriving in: </Text>
							{this.props.stopData.etaMinutes}
						</Text>
					</View>
				</View>
			</TouchableHighlight>
		);
	}
}
