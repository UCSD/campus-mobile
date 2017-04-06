import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	ActivityIndicator
} from 'react-native';

import BlueDot from '../common/BlueDot';
import ShuttleSmallList from './ShuttleSmallList';
import { getMinutesETA } from '../../util/shuttle';

const css = require('../../styles/css');

const ShuttleOverview = ({ onPress, stopData, closest }) => {
	if (stopData.arrivals && stopData.arrivals.length > 0) {
		return (
			<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => onPress()}>
				<View>
					<View style={css.shuttle_card_row}>
						<View style={css.shuttle_card_row_top}>
							<View style={css.shuttle_card_rt_1} />
							<View style={[css.shuttle_card_rt_2, { backgroundColor: stopData.arrivals[0].route.color, borderColor: stopData.arrivals[0].route.color }]}>
								<Text style={css.shuttle_card_rt_2_label}>
									{stopData.arrivals[0].route.shortName}
								</Text>
							</View>
							<View style={css.shuttle_card_rt_3}>
								<Text style={css.shuttle_card_rt_3_label}>@</Text>
							</View>
							<View style={css.shuttle_card_rt_4}>
								<Text
									style={css.shuttle_card_rt_4_label}
									numberOfLines={3}
								>
									{stopData.name}
								</Text>
							</View>
							<View style={css.shuttle_card_rt_5} />
						</View>
						<View style={css.shuttle_card_row_bot}>
							<Text
								style={css.shuttle_card_row_name}
								numberOfLines={1}
							>
								{stopData.arrivals[0].route.name}
							</Text>
							<Text style={css.shuttle_card_row_arriving}>
								{getMinutesETA(stopData.arrivals[0].secondsToArrival)}
							</Text>
						</View>
						{
							(closest) ? (
								<BlueDot style={{ right: 0, bottom: 0, position: 'absolute' }} />) : (null)
						}
					</View>
					<ShuttleSmallList
						arrivalData={stopData.arrivals.slice(1,3)}
						rows={2}
						scrollEnabled={false}
					/>
				</View>
			</TouchableHighlight>
		);
	} else {
		return (
			<View>
				<View style={css.shuttle_card_row}>
					<View style={css.shuttle_card_row_top}>
						<View style={css.shuttle_card_rt_1} />
						<View style={css.shuttle_card_rt_2}>
							<ActivityIndicator
								animating={true}
								size="small"
							/>
						</View>
						<View style={css.shuttle_card_rt_3}>
							{
								(closest) ? (
									<BlueDot />) : (<Text style={css.shuttle_card_rt_3_label}>@</Text>)
							}
						</View>
						<View style={css.shuttle_card_rt_4}>
							<Text
								style={css.shuttle_card_rt_4_label}
								numberOfLines={3}
							>
								{stopData.name}
							</Text>
						</View>
						<View style={css.shuttle_card_rt_5} />
					</View>
					<View style={css.shuttle_card_row_bot} />
				</View>
			</View>
		);
	}
};

export default ShuttleOverview;
