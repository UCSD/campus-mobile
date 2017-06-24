import React from 'react';
import { Alert } from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';
import Toast from 'react-native-simple-toast';

import { updateMaster } from '../../actions/shuttle';
import ShuttleCard from './ShuttleCard';

import logger from '../../util/logger';

class ShuttleCardContainer extends React.Component {
	componentDidMount() {
		logger.ga('Card Mounted: Shuttle');
		this.props.updateMaster();
	}

	render() {
		const { stopsData, savedStops, removeStop, closestStop, updateScroll, lastScroll } = this.props;

		const displayStops = savedStops.slice();
		if (closestStop) {
			displayStops.splice(closestStop.savedIndex, 0, closestStop);
		}

		return (<ShuttleCard
			savedStops={displayStops}
			stopsData={stopsData}
			gotoSavedList={this.gotoSavedList}
			gotoRoutesList={this.gotoRoutesList}
			removeStop={removeStop}
			updateScroll={updateScroll}
			lastScroll={lastScroll}
		/>);
	}

	gotoRoutesList = () => {
		if (Array.isArray(this.props.savedStops) && this.props.savedStops.length < 10) {
			const { shuttle_routes } = this.props;
			// Sort routes by alphabet
			const alphaRoutes = [];
			Object.keys(shuttle_routes)
				.sort((a, b) => shuttle_routes[a].name.trim().localeCompare(shuttle_routes[b].name.trim()))
					.forEach((key) => {
						alphaRoutes.push(shuttle_routes[key]);
					});
			Actions.ShuttleRoutesListView({ shuttle_routes: alphaRoutes, gotoStopsList: this.gotoStopsList });
		} else {
			Alert.alert(
				'Add a Stop',
				'Unable to add more than 10 stops, please remove a stop and try again.',
				[
					{ text: 'Manage Stops', onPress: () => this.gotoSavedList() },
					{ text: 'Cancel' }
				]
			);
		}
	}

	isSaved = (stop) => {
		const { savedStops } = this.props;

		if (Array.isArray(savedStops)) {
			for (let i = 0; i < savedStops.length; ++i) {
				if (savedStops[i].id === stop.id) {
					return true;
				}
			}
		}
		return false;
	}

	gotoStopsList = (stops) => {
		// Sort stops by alphabet
		const alphaStops = [];
		Object.keys(stops)
			.sort((a, b) => stops[a].name.trim().localeCompare(stops[b].name.trim()))
				.forEach((key) => {
					const stop = Object.assign({}, stops[key]);

					if (this.isSaved(stop)) {
						stop.saved = true;
					}
					alphaStops.push(stop);
				});

		Actions.ShuttleStopsListView({ shuttle_stops: alphaStops, addStop: this.addStop });
	}

	gotoSavedList = () => {
		Actions.ShuttleSavedListView({ gotoRoutesList: this.gotoRoutesList });
	}

	addStop = (stopID, stopName) => {
		logger.ga('Shuttle: Added stop "' + stopName + '"');
		Toast.showWithGravity('Stop added.', Toast.SHORT, Toast.CENTER);
		this.props.addStop(stopID); // dispatch saga
		Actions.popTo('Home'); // pop back to home
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
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		updateMaster: () => {
			dispatch(updateMaster());
		},
		addStop: (stopID) => {
			dispatch({ type: 'ADD_STOP', stopID });
		},
		updateScroll: (scrollX) => {
			dispatch({ type: 'UPDATE_SHUTTLE_SCROLL', scrollX });
		}
	};
}

const ActualShuttleCard = connect(
	mapStateToProps,
	mapDispatchtoProps
)(ShuttleCardContainer);

export default ActualShuttleCard;
