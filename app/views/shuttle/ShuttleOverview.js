import React from 'react'
import { View, Text, ActivityIndicator } from 'react-native'
import FAIcon from 'react-native-vector-icons/FontAwesome'

import BlueDot from '../common/BlueDot'
import ShuttleSmallList from './ShuttleSmallList'
import LocationRequiredContent from '../common/LocationRequiredContent'
import { getMinutesETA } from '../../util/shuttle'
import { openURL } from '../../util/general'
import AppSettings from '../../AppSettings'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

const ShuttleOverview = ({ onPress, stopData, closest }) => {
	if (!stopData) {
		return null
	} else if (closest && !stopData) {
		return (<LocationRequiredContent />)
	} else if (Array.isArray(stopData.arrivals) && stopData.arrivals.length > 0) {
		return (
			<Touchable onPress={() => onPress()}>
				<View style={css.so_bigContainer}>
					<View style={css.so_bigCircles}>
						<View style={[css.so_shortNameCircle, { backgroundColor: stopData.arrivals[0].route.color }]}>
							<Text style={css.so_shortNameText} allowFontScaling={false}>
								{stopData.arrivals[0].route.shortName}
							</Text>
						</View>
						<View style={css.so_atContainer}>
							<Text style={css.so_atText}>@</Text>
						</View>
						<View style={css.so_stopNameCircle}>
							<Text
								style={css.so_stopNameText}
								numberOfLines={3}
								allowFontScaling = {false}
							>
								{stopData.name}
							</Text>
						</View>
					</View>
					<View style={css.so_infoContainer}>
						<Text
							style={css.so_routeNameText}
							numberOfLines={1}
						>
							{stopData.arrivals[0].route.name}
						</Text>
						<Text style={css.so_arrivingText}>
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
		)
	} else {
		return (
			<View>
				<View style={css.so_bigContainer}>
					<View style={css.so_bigCircles}>

						<View style={css.so_stopNameCircle}>
							<Text style={[css.so_shortNameText, css.so_shortNameTextLoading]}>
								?
							</Text>
						</View>

						<View style={css.so_atContainer}>
							<ActivityIndicator
								animating={true}
								size="small"
							/>
						</View>
						<View style={css.so_stopNameCircle}>
							<Text
								style={css.so_stopNameText}
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
				<View style={css.so_noShuttleContainer}>
					<Text style={css.so_noShuttleText}>
						Sorry, no buses appear to be en route{ stopData && stopData.name ? ' to ' + stopData.name : null }.
					</Text>

					<Touchable onPress={() => openURL(AppSettings.SHUTTLE_SCHEDULE_URL)}>
						<View style={css.so_scheduleContainer}>
							<FAIcon name="bus" size={18} style={css.so_busIcon} />
							<Text style={css.so_scheduleText}>Check Bus Schedule</Text>
						</View>
					</Touchable>
				</View>
			</View>
		)
	}
}

export default ShuttleOverview
