import React from 'react'
import { Alert } from 'react-native'
import { connect } from 'react-redux'
import { withNavigation } from 'react-navigation'
import Toast from 'react-native-simple-toast'
import ShuttleCard from './ShuttleCard'
import logger from '../../util/logger'

export class ShuttleCardContainer extends React.Component {
	gotoRoutesList = (navigation) => {
		if (Array.isArray(this.props.savedStops) && this.props.savedStops.length < 10) {
			const { shuttle_routes } = this.props
			// Sort routes by alphabet
			const alphaRoutes = []
			Object.keys(shuttle_routes)
				.sort((a, b) => shuttle_routes[a].name.trim().localeCompare(shuttle_routes[b].name.trim()))
				.forEach((key) => {
					alphaRoutes.push(shuttle_routes[key])
				})
			navigation.navigate('ShuttleRoutesListView', { shuttle_routes: alphaRoutes, gotoStopsList: this.gotoStopsList })
		} else {
			Alert.alert(
				'Add a Stop',
				'Unable to add more than 10 stops, please remove a stop and try again.',
				[
					{ text: 'Manage Stops', onPress: () => this.gotoSavedList() },
					{ text: 'Cancel' }
				]
			)
		}
	}

	isSaved = (stop) => {
		const { savedStops } = this.props

		if (Array.isArray(savedStops)) {
			for (let i = 0; i < savedStops.length; ++i) {
				if (savedStops[i].id === stop.id) {
					return true
				}
			}
		}
		return false
	}

	gotoStopsList = (stops) => {
		const { navigation } = this.props

		// Sort stops by alphabet
		const alphaStops = []
		Object.keys(stops)
			.sort((a, b) => stops[a].name.trim().localeCompare(stops[b].name.trim()))
			.forEach((key) => {
				const stop = Object.assign({}, stops[key])

				if (this.isSaved(stop)) {
					stop.saved = true
				}
				alphaStops.push(stop)
			})

		navigation.navigate('ShuttleStopsListView', { shuttle_stops: alphaStops, addStop: this.addStop })
	}

	gotoSavedList = () => {
		const { navigation } = this.props
		navigation.navigate('ShuttleSavedListView', { gotoRoutesList: this.gotoRoutesList })
	}

	addStop = (stopID, stopName) => {
		const { navigation } = this.props
		logger.trackScreen('Shuttle: Added stop "' + stopName + '"')
		Toast.showWithGravity('Stop added.', Toast.SHORT, Toast.CENTER)
		this.props.addStop(stopID)
		navigation.popToTop()
	}

	render() {
		const {
			navigation,
			stopsData,
			savedStops,
			removeStop,
			closestStop,
			updateScroll,
			lastScroll
		} = this.props

		const displayStops = savedStops.slice()
		if (closestStop) {
			displayStops.splice(closestStop.savedIndex, 0, closestStop)
		}

		return (<ShuttleCard
			savedStops={displayStops}
			stopsData={stopsData}
			gotoSavedList={this.gotoSavedList}
			gotoRoutesList={() => this.gotoRoutesList(navigation)}
			removeStop={removeStop}
			updateScroll={updateScroll}
			lastScroll={lastScroll}
		/>)
	}
}

function mapStateToProps(state, props) {
	return {
		closestStop: state.shuttle.closestStop,
		stopsData: state.shuttle.stops,
		shuttle_routes: state.shuttle.routes,
		shuttle_stops: state.shuttle.stops,
		savedStops: state.shuttle.savedStops,
		lastScroll: state.shuttle.lastScroll
	}
}

function mapDispatchtoProps(dispatch) {
	return {
		addStop: (stopID) => {
			dispatch({ type: 'ADD_STOP', stopID })
		},
		updateScroll: (scrollX) => {
			dispatch({ type: 'UPDATE_SHUTTLE_SCROLL', scrollX })
		}
	}
}

const ActualShuttleCard = connect(mapStateToProps, mapDispatchtoProps)(withNavigation(ShuttleCardContainer))
export default ActualShuttleCard
