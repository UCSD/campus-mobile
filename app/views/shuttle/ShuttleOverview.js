import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
} from 'react-native';

import Icon from 'react-native-vector-icons/FontAwesome';
import ElevatedView from 'react-native-elevated-view';

import ShuttleSmallList from './ShuttleSmallList';
import { getMinutesETA } from '../../util/shuttle';

const css = require('../../styles/css');

const ShuttleOverview = ({ onPress, stopData }) => {
	if (stopData.arrivals && stopData.arrivals.length > 0) {
		return (
			<ElevatedView
				style={{ margin: 0, backgroundColor: 'white' }}
				elevation={2}
			>
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
									<Text style={css.grey}>Arriving in: </Text>
									{getMinutesETA(stopData.arrivals[0].secondsToArrival)}
								</Text>
							</View>
						</View>
						<ShuttleSmallList
							arrivalData={stopData.arrivals.slice(1,3)}
							rows={2}
							scrollEnabled={false}
						/>
					</View>
				</TouchableHighlight>
			</ElevatedView>
		);
	} else {
		return (
			<ElevatedView
				style={{ margin: 0, backgroundColor: 'white' }}
				elevation={2}
			>
				<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => onPress()}>
					<View>
						<View style={css.shuttle_card_row}>
							<View style={css.shuttle_card_row_top}>
								<View style={css.shuttle_card_rt_1} />
								<View style={[css.shuttle_card_rt_2, { backgroundColor: 'grey', borderColor: 'grey' }]}>
									<Icon
										name="ban"
										size={20}
									/>
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
									Nobody is coming for you.
								</Text>
								<Text style={css.shuttle_card_row_arriving}>
									<Text style={css.grey}>Arriving in: </Text>
									Never o' clock
								</Text>
							</View>
						</View>
					</View>
				</TouchableHighlight>
			</ElevatedView>
		);
	}
}

export default ShuttleOverview;

/*
<ElevatedView
		style={{ margin: 0, backgroundColor: 'white' }}
		elevation={2}
	>
		<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => onPress()}>
			<View>
				<View style={css.shuttle_card_row}>
					<View style={css.shuttle_card_row_top}>
						<View style={css.shuttle_card_rt_1} />
						<View style={[css.shuttle_card_rt_2, { backgroundColor: stopData[stopID].arrivals[0].route.color, borderColor: stopData[stopID].arrivals[0].route.color }]}>
							<Text style={css.shuttle_card_rt_2_label}>
								{stopData[stopID].arrivals[0].route.shortName}
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
								{stopData[stopID].name}
							</Text>
						</View>
						<View style={css.shuttle_card_rt_5} />
					</View>
					<View style={css.shuttle_card_row_bot}>
						<Text
							style={css.shuttle_card_row_name}
							numberOfLines={1}
						>
							{stopData[stopID].arrivals[0].route.name}
						</Text>
						<Text style={css.shuttle_card_row_arriving}>
							<Text style={css.grey}>Arriving in: </Text>
							{getMinutesETA(stopData[stopID].arrivals[0].secondsToArrival)}
						</Text>
					</View>
				</View>
				<ShuttleSmallList
					arrivalData={stopData[stopID].arrivals.slice(1,3)}
					rows={2}
					scrollEnabled={false}
				/>
			</View>
		</TouchableHighlight>
	</ElevatedView>
 */