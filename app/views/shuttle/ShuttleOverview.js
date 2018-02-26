import React from 'react';
import {
	View,
	Text,
	ActivityIndicator,
	StyleSheet
} from 'react-native';
import FAIcon from 'react-native-vector-icons/FontAwesome';

import BlueDot from '../common/BlueDot';
import ShuttleSmallList from './ShuttleSmallList';
import LocationRequiredContent from '../common/LocationRequiredContent';
import { getMinutesETA } from '../../util/shuttle';
import { openURL } from '../../util/general';
import AppSettings from '../../AppSettings';
import Touchable from '../common/Touchable';
import {
	MAX_CARD_WIDTH
} from '../../styles/LayoutConstants';
import {
	COLOR_PRIMARY,
	COLOR_WHITE,
	COLOR_MGREY,
	COLOR_BLACK,
	COLOR_DGREY
} from '../../styles/ColorConstants';

const ShuttleOverview = ({ onPress, stopData, closest }) => {
	if (!stopData) {
		return null;
	} else if (closest && !stopData) {
		return (<LocationRequiredContent />);
	} else if (Array.isArray(stopData.arrivals) && stopData.arrivals.length > 0) {
		return (
			<Touchable onPress={() => onPress()}>
				<View style={styles.bigContainer}>
					<View style={styles.bigCircles}>
						<View style={[styles.shortNameCircle, { backgroundColor: stopData.arrivals[0].route.color }]}>
							<Text style={styles.shortNameText} allowFontScaling={false}>
								{stopData.arrivals[0].route.shortName}
							</Text>
						</View>
						<View style={styles.atContainer}>
							<Text style={styles.atText}>@</Text>
						</View>
						<View style={styles.stopNameCircle}>
							<Text
								style={styles.stopNameText}
								numberOfLines={3}
								allowFontScaling = {false}
							>
								{stopData.name}
							</Text>
						</View>
					</View>
					<View style={styles.infoContainer}>
						<Text
							style={styles.routeNameText}
							numberOfLines={1}
						>
							{stopData.arrivals[0].route.name}
						</Text>
						<Text style={styles.arrivingText}>
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
			</Touchable>
		);
	} else {
		return (
			<View>
				<View style={styles.bigContainer}>
					<View style={styles.bigCircles}>

						<View style={styles.stopNameCircle}>
							<Text style={[styles.shortNameText, styles.shortNameTextLoading]}>
								?
							</Text>
						</View>

						<View style={styles.atContainer}>
							<ActivityIndicator
								animating={true}
								size="small"
							/>
						</View>
						<View style={styles.stopNameCircle}>
							<Text
								style={styles.stopNameText}
								numberOfLines={3}
							>
								{stopData.name}
							</Text>
						</View>
					</View>
					{ (closest) ? (
						<BlueDot dotSize={20} dotStyle={{ right: 2, bottom: 2, position: 'absolute' }} />
					) : null }
				</View>
				<View style={styles.noShuttleContainer}>
					<Text style={styles.noShuttleText}>
						Sorry, no buses appear to be en route{ stopData && stopData.name ? ' to ' + stopData.name : null }.
					</Text>

					<Touchable onPress={() => openURL(AppSettings.SHUTTLE_SCHEDULE_URL)}>
						<View style={styles.scheduleContainer}>
							<FAIcon name="bus" size={18} style={styles.busIcon} />
							<Text style={styles.scheduleText}>Check Bus Schedule</Text>
						</View>
					</Touchable>
				</View>
			</View>
		);
	}
};

const styles = StyleSheet.create({
	busIcon: { color: COLOR_PRIMARY },
	bigContainer: { width: MAX_CARD_WIDTH, borderBottomWidth: 1, borderBottomColor: COLOR_MGREY },
	bigCircles: { flexDirection: 'row', alignItems: 'stretch', justifyContent: 'center', margin: 20, height: 83 },
	shortNameCircle: { borderRadius: 50, width: 83, justifyContent: 'center', overflow: 'hidden', padding: 2 },
	shortNameText: { textAlign: 'center', color: COLOR_BLACK, fontWeight: '600', fontSize: 48, backgroundColor: 'transparent' },
	shortNameTextLoading: { color: COLOR_DGREY },
	atContainer: { flexGrow: 3, justifyContent: 'center', alignItems: 'center' },
	atText: { textAlign: 'center', color: COLOR_DGREY, fontSize: 30, fontWeight: '300', backgroundColor: 'transparent' },
	stopNameCircle: { borderRadius: 48, borderWidth: 1, backgroundColor: COLOR_WHITE, borderColor: COLOR_MGREY, width: 83, justifyContent: 'center', padding: 2 },
	stopNameText: { padding: 5, textAlign: 'center', color: COLOR_DGREY, fontWeight: '500', fontSize: 16, backgroundColor: 'transparent' },
	infoContainer: { alignItems: 'center', paddingBottom: 10, paddingHorizontal: 8 },
	routeNameText: { fontSize: 17, color: COLOR_BLACK },
	arrivingText: { fontSize: 26, color: COLOR_DGREY },
	noShuttleContainer: { width: MAX_CARD_WIDTH, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 30, paddingVertical: 20 },
	noShuttleText: { lineHeight: 28, fontSize: 15, color: COLOR_BLACK, textAlign: 'center' },
	scheduleContainer: { flexDirection: 'row', marginTop: 10, justifyContent: 'center', alignItems: 'center' },
	scheduleText: { color: COLOR_PRIMARY, fontSize: 20, paddingLeft: 8 },
});

export default ShuttleOverview;
