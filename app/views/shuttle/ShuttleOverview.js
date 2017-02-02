import React from 'react';
import {
	View,
	Text,
	TouchableHighlight,
	StyleSheet,
	ListView
} from 'react-native';

import { getPRM, round } from '../../util/general';
import { getMinutesETA } from '../../util/shuttle';

const css = require('../../styles/css');

/*
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
}*/

const arrivalDataSource = new ListView.DataSource({ rowHasChanged: (r1, r2) => r1 !== r2 });

const ShuttleOverview = ({ onPress, stopData, shuttleData }) => (
	<View>
		<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => onPress(stopData, shuttleData)}>
			<View style={css.shuttle_card_row}>
				<View style={css.shuttle_card_row_top}>
					<View style={css.shuttle_card_rt_1} />
					<View style={[css.shuttle_card_rt_2, { backgroundColor: stopData.routeColor, borderColor: stopData.routeColor }]}>
						<Text style={css.shuttle_card_rt_2_label}>{stopData.routeShortName}</Text>
					</View>
					<View style={css.shuttle_card_rt_3}>
						<Text style={css.shuttle_card_rt_3_label}>@</Text>
					</View>
					<View style={css.shuttle_card_rt_4}>
						<Text style={css.shuttle_card_rt_4_label} numberOfLines={3}>{stopData.stopName}</Text>
					</View>
					<View style={css.shuttle_card_rt_5} />
				</View>
				<View style={css.shuttle_card_row_bot}>
					<Text style={css.shuttle_card_row_arriving}>
						<Text style={css.grey}>Arriving in: </Text>
						{stopData.etaMinutes}
					</Text>
				</View>
			</View>
		</TouchableHighlight>
		<Text style={styles.shuttle_stop_next_arrivals_text}>
			Next Arrivals
		</Text>
		<View
			style={styles.next_rows}
		>
			<ShuttleSmallList
				arrivalData={arrivalDataSource.cloneWithRows(shuttleData)}
			/>
		</View>
	</View>
);

const ShuttleSmallList = ({ arrivalData }) => (
	<ListView
		showsVerticalScrollIndicator={false}
		dataSource={arrivalData}
		renderRow={
			(row, sectionID, rowID) =>
				<ShuttleSmallRow
					arrival={row}
				/>
		}
	/>
);

const ShuttleSmallRow = ({ arrival }) => (
	<View style={styles.shuttle_stop_arrivals_row}>
		<View style={[styles.shuttle_stop_rt_2, { backgroundColor: arrival.route.color, borderColor: arrival.route.color }]}>
			<Text style={styles.shuttle_stop_rt_2_label}>
				{(arrival.route.shortName === 'Campus Loop') ?
					('L') : (arrival.route.shortName)
				}
			</Text>
		</View>
		<Text
			style={styles.shuttle_stop_arrivals_row_route_name}
			numberOfLines={1}
		>
			{arrival.route.name}
		</Text>
		<Text style={styles.shuttle_stop_arrivals_row_eta_text}>{getMinutesETA(arrival.secondsToArrival)}</Text>
	</View>
);

const styles = StyleSheet.create({
	next_rows: { height: (2 * round(36 * getPRM())) + 32 },
	shuttle_stop_next_arrivals_text: { fontSize: round(20 * getPRM()), fontWeight: '300', color: '#222', padding: 8 },
	shuttle_stop_arrivals_row: { flexDirection: 'row', padding: 8, alignItems: 'center', justifyContent: 'flex-start' },
	shuttle_stop_rt_2: { borderRadius: round(18 * getPRM()), width: round(36 * getPRM()), height: round(36 * getPRM()), justifyContent: 'center' },
	shuttle_stop_rt_2_label: { textAlign: 'center', fontWeight: '600', fontSize: round(19 * getPRM()), backgroundColor: 'rgba(0,0,0,0)' },
	shuttle_stop_arrivals_row_route_name: { flex: 2, fontSize: round(17 * getPRM()), color: '#555', paddingLeft: round(10 * getPRM()) },
	shuttle_stop_arrivals_row_eta_text: { flex: 1, fontSize: round(20 * getPRM()), color: '#333', paddingLeft: round(16 * getPRM()), paddingRight: round(16 * getPRM()) },
});

export default ShuttleOverview;
