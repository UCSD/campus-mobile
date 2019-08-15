import React from 'react'
import { Text, Image, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import MapView from 'react-native-maps'

import ShuttleSmallList from './ShuttleSmallList'
import ShuttleImageDict from './ShuttleImageDict'
import logger from '../../util/logger'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

class ShuttleStopContainer extends React.Component {
	componentDidMount() {
		logger.trackScreen('View Mounted: Shuttle Stop')
	}

	render() {
		const { navigation, stops, location } = this.props
		const { stopID } = navigation.state.params
		return (
			<ScrollView style={css.scroll_default} contentContainerStyle={css.main_full}>
				{ShuttleImageDict[stopID] ? (
					<Image style={css.ss_shuttlestop_image} source={ShuttleImageDict[stopID]} />
				) : null }
				<Text style={css.ss_nameText}>{stops.name}</Text>

				{ (stops.arrivals) ? (
					<ShuttleSmallList
						arrivalData={stops.arrivals.slice(0,3)}
						rows={3}
						scrollEnabled={false}
					/>
				) : (
					<Text style={css.ss_arrivalsText}>There are no active shuttles at this time</Text>
				)}
				<MapView
					style={css.ss_map}
					loadingEnabled={true}
					loadingIndicatorColor={COLOR.DGRAY}
					loadingBackgroundColor={COLOR.WHITE}
					showsUserLocation={true}
					mapType="standard"
					initialRegion={{
						latitude: location.coords.latitude,
						longitude: location.coords.longitude,
						latitudeDelta: 0.1,
						longitudeDelta: 0.1,
					}}
				>
					<MapView.Marker
						coordinate={{
							latitude: stops.lat,
							longitude: stops.lon
						}}
						title={stops.lat.name}
						description={stops.lat.name}
						key={stops.lat.name}
					/>
				</MapView>
			</ScrollView>
		)
	}
}

function mapStateToProps(state, props) {
	const { stopID } = props.navigation.state.params
	return {
		location: state.location.position,
		stops: state.shuttle.stops[stopID],
	}
}

const ActualShuttleStop = connect(mapStateToProps)(ShuttleStopContainer)

export default ActualShuttleStop
