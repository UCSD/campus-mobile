import React from 'react';
import {
	View,
	Text,
	Image,
	ScrollView,
	StyleSheet
} from 'react-native';
import { connect } from 'react-redux';
import MapView from 'react-native-maps';

import ShuttleSmallList from './ShuttleSmallList';
import ShuttleImageDict from './ShuttleImageDict';
import css from '../../styles/css';
import logger from '../../util/logger';
import {
	WINDOW_WIDTH
} from '../../styles/LayoutConstants';
import {
	COLOR_PRIMARY,
	COLOR_WHITE,
	COLOR_DGRAY
} from '../../styles/ColorConstants';

class ShuttleStopContainer extends React.Component {
	componentDidMount() {
		logger.ga('View Mounted: Shuttle Stop');
	}

	render() {
		const { stopID, stops, location } = this.props;
		return (
			<ScrollView
				style={css.main_full}
			>
				{ShuttleImageDict[stopID] ? (
					<Image style={styles.shuttlestop_image} source={ShuttleImageDict[stopID]} />
				) : null }
				<Text style={styles.nameText}>{stops.name}</Text>

				{ (stops.arrivals) ? (
					<ShuttleSmallList
						arrivalData={stops.arrivals.slice(0,3)}
						rows={3}
						scrollEnabled={false}
					/>
				) : (
					<Text style={styles.arrivalsText}>There are no active shuttles at this time</Text>
				)}
				<MapView
					style={styles.map}
					loadingEnabled={true}
					loadingIndicatorColor={COLOR_DGRAY}
					loadingBackgroundColor={COLOR_WHITE}
					showsUserLocation={true}
					mapType={'standard'}
					initialRegion={{
						latitude: location.coords.latitude,
						longitude: location.coords.longitude,
						latitudeDelta: 0.1,
						longitudeDelta: 0.1,
					}}
				>
					<MapView.Marker
						coordinate={{ latitude: stops.lat,
							longitude: stops.lon }}
						title={stops.lat.name}
						description={stops.lat.name}
						key={stops.lat.name}
					/>
				</MapView>
			</ScrollView>
		);
	}
}

function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		stops: state.shuttle.stops[props.stopID],
	};
}

const ActualShuttleStop = connect(
	mapStateToProps
)(ShuttleStopContainer);

const styles = StyleSheet.create({
	shuttlestop_image: { width: WINDOW_WIDTH, height: Math.round(WINDOW_WIDTH * 0.533) },
	nameText: { flex: 1, flexDirection: 'row', alignItems: 'center', width: WINDOW_WIDTH, paddingVertical: 10, paddingHorizontal: 14, backgroundColor: COLOR_PRIMARY, color: COLOR_WHITE, fontSize: 24, fontWeight: '300' },
	arrivalsText: { width: WINDOW_WIDTH, padding: 16, fontSize: 20, fontWeight: '300', color: COLOR_DGRAY },
	mapContainer: { margin: 1 },
	map: { margin: 1, width: WINDOW_WIDTH, height: Math.round(WINDOW_WIDTH * 0.8) },
});

export default ActualShuttleStop;
