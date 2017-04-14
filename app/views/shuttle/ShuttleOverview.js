import React from 'react';
import {
	View,
	Text,
	TouchableOpacity,
	ActivityIndicator
} from 'react-native';

import BlueDot from '../common/BlueDot';
import ShuttleSmallList from './ShuttleSmallList';
import LocationRequiredContent from '../common/LocationRequiredContent';
import { getMinutesETA } from '../../util/shuttle';
import { openURL } from '../../util/general';
import FAIcon from 'react-native-vector-icons/FontAwesome';
import AppSettings from '../../AppSettings';

const css = require('../../styles/css');

const ShuttleOverview = ({ onPress, stopData, closest }) => {
	if (!stopData) {
		return null;
	} else if (closest && !stopData) {
		return (<LocationRequiredContent />);
	} else if (stopData.arrivals && stopData.arrivals.length > 0) {
		return (
			<TouchableOpacity onPress={() => onPress()}>
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
								{stopData.arrivals[0].secondsToArrival <= 0 ? 'Arrived' : null}
								{stopData.arrivals[0].secondsToArrival > 0 ? 'Arriving in: ' + getMinutesETA(stopData.arrivals[0].secondsToArrival) : null}
							</Text>
						</View>
						{ (closest) ? (
							<BlueDot dotSize={20} dotStyle={{ right: 2, bottom: 2, position: 'absolute' }} />
						) : null }
					</View>
					<ShuttleSmallList
						arrivalData={stopData.arrivals.slice(1,3)}
						rows={2}
						scrollEnabled={false}
					/>
				</View>
			</TouchableOpacity>
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
				<View style={css.sc_no_shuttle_container}>
					<Text style={css.sc_no_shuttle_text}>
						Sorry, no buses appear to be en route{ stopData && stopData.name ? ' to ' + stopData.name : null }.
					</Text>

					<TouchableOpacity onPress={() => openURL(AppSettings.SHUTTLE_SCHEDULE_URL)}>
						<View style={css.sc_bus_schedule_container}>
							<FAIcon name='bus' size={18} color={'#182B49'} />
							<Text style={css.sc_bus_schedule_text}>Check Bus Schedule</Text>
						</View>
					</TouchableOpacity>
				</View>
			</View>
		);
	}
};

export default ShuttleOverview;
