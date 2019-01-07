import React, { Component } from 'react'
// import PropTypes from 'prop-types'
import { StyleSheet } from 'react-native'
import MapView from 'react-native-maps'
import Icon from 'react-native-vector-icons/FontAwesome'
import COLOR from '../../styles/ColorConstants'

// NOTE: For some reason MapView-onCalloutPress only works for Android and
// TouchableHighlight-onPress only works for iOS...which is why it's in two places
class SearchMap extends Component {
	constructor(props) {
		super(props)
		this.state = {
			searchMarkerCallout: {
				selectedResult: null,
				alreadyAutoShown: false,
				beingDeselected: false
			}
		}
	}

	hideSearchMarkerCallout = () => {
		if (this.searchMarker &&
			this.searchMarker.hideCallout &&
			!this.state.searchMarkerCallout.beingDeselected) {
			this.searchMarker.hideCallout()
		}
	}

	showSearchMarkerCallout = () => {
		if (this.searchMarker && this.searchMarker.showCallout) {
			if (this.state.searchMarkerCallout.selectedResult
				!== this.props.selectedResult &&
				!this.state.searchMarkerCallout.shown
			) {
				this.setState({
					searchMarkerCallout: {
						selectedResult: this.props.selectedResult,
						alreadyAutoShown: true
					}
				}, () => {
					this.searchMarker.showCallout()
				})
			}
		}
	}

	render() {
		const {
			location,
			selectedResult,
			shuttle,
			vehicles,
		} = this.props

		let shuttleVehicles = null
		if (shuttle && (Object.keys(vehicles).length !== 0)) {
			shuttleVehicles = (
				// Create MapView.Marker for each vehicle
				Object.keys(vehicles).map((key, index) => {
					const vehicleArray = vehicles[key]

					return vehicleArray.map(vehicle => (
						<MapView.Marker.Animated
							coordinate={vehicle.animated}
							title={vehicle.name}
							identifier={vehicle.name}
							key={vehicle.name}
						>
							<Icon name="bus" size={20} color={COLOR.SECONDARY} />
						</MapView.Marker.Animated>
					))
				})
			)
		}

		let shuttleStops = null
		if (shuttle && (Object.keys(vehicles).length !== 0)) {
			// Create MapView.Marker for each shuttle stop
			shuttleStops = Object.keys(shuttle).map((key, index) => {
				const stop = shuttle[key]
				if ((Object.keys(stop.routes).length === 0 && stop.routes.constructor === Object) ||
					// Hide Airport stops
					stop.routes['89']) {
					return null
				}

				return (
					<MapView.Marker
						coordinate={{
							latitude: stop.lat,
							longitude: stop.lon
						}}
						title={stop.name}
						identifier={stop.name}
						key={stop.name + key}
						pinColor={COLOR.PIN}
					>
						<Icon
							style={{
								textAlign: 'center',
								height: 10,
								width: 10,
								borderWidth: 1,
								borderRadius: 5,
								borderColor: COLOR.PIN
							}}
							name="circle"
							color="white"
							size={10}
						/>
					</MapView.Marker>
				)
			})
		}

		let searchResultMarker = null
		if (selectedResult) {
			searchResultMarker = (
				<MapView.Marker
					coordinate={{
						latitude: selectedResult.mkrLat,
						longitude: selectedResult.mkrLong
					}}
					title={selectedResult.title}
					identifier={selectedResult.title}
					key={selectedResult.title}
					stopPropagation
					ref={(ref) => { this.searchMarker = ref }}
					onDeselect={() => {
						this.setState({
							searchMarkerCallout: {
								...this.state.searchMarkerCallout,
								beingDeselected: true
							}
						})
					}}
				/>
			)
		}

		return (
			<MapView
				ref={(MapRef) => {
					if ( MapRef != null && selectedResult != null && this._lastResult !== selectedResult) {
						this._lastResult = selectedResult // Make sure not to re-zoom if already did so for this result

						// Calculate center region and animate to it
						const midLat = (location.coords.latitude + selectedResult.mkrLat) / 2
						const midLong = (location.coords.longitude + selectedResult.mkrLong) / 2
						const minLat = (location.coords.latitude < selectedResult.mkrLat) ? location.coords.latitude : selectedResult.mkrLat
						const minLong = (location.coords.longitude < selectedResult.mkrLong) ? location.coords.longitude : selectedResult.mkrLong
						const maxLat = (location.coords.latitude > selectedResult.mkrLat) ? location.coords.latitude : selectedResult.mkrLat
						const maxLong = (location.coords.longitude > selectedResult.mkrLong) ? location.coords.longitude : selectedResult.mkrLong
						const deltaLat = (maxLat - minLat) + 0.02
						const deltaLong = (maxLong - minLong) + 0.02

						const midRegion = {
							latitude: midLat,
							longitude: midLong,
							latitudeDelta: deltaLat,
							longitudeDelta: deltaLong,
						}
						MapRef.animateToRegion(midRegion, 1000)
					}
				}}
				style={styles.map_container}
				loadingEnabled={true}
				loadingIndicatorColor={COLOR.DGREY}
				loadingBackgroundColor={COLOR.MGREY}
				showsUserLocation={true}
				mapType="standard"
				initialRegion={{
					latitude: location.coords.latitude,
					longitude: location.coords.longitude,
					latitudeDelta: 0.02,
					longitudeDelta: 0.02
				}}
				onRegionChangeComplete={() => {
					if (selectedResult && this.searchMarker) {
						this.showSearchMarkerCallout()
					}
				}}
				onPress={() => { this.hideSearchMarkerCallout() }}
			>
				{shuttleVehicles}
				{shuttleStops}
				{searchResultMarker}
			</MapView>
		)
	}
}

SearchMap.propTypes = {
	// location: PropTypes.object,
	// selectedResult: PropTypes.object,
}

SearchMap.defaultProps = {
	// location: null,
	// selectedResult: null,
}

const styles = StyleSheet.create({ map_container: { ...StyleSheet.absoluteFillObject } })

export default SearchMap
