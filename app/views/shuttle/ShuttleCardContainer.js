import React from 'react';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';
import Toast from 'react-native-simple-toast';

import { updateMaster } from '../../actions/shuttle';
import CardComponent from '../card/CardComponent';
import ShuttleCard from './ShuttleCard';

import logger from '../../util/logger';

class ShuttleCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Shuttle');
		this.props.updateMaster();
	}

	render() {
		const { stopsData, savedStops, removeStop, closestStop } = this.props;

		const displayStops = savedStops.slice();
		console.log('render');
		if (closestStop) {
			displayStops.splice(closestStop.savedIndex, 0, closestStop);
		}

		return (<ShuttleCard
			savedStops={displayStops}
			stopsData={stopsData}
			gotoSavedList={this.gotoSavedList}
			gotoRoutesList={this.gotoRoutesList}
			removeStop={removeStop}
		/>);
	}

	gotoRoutesList = () => {
		const { shuttle_routes } = this.props;
		// Sort routes by alphabet
		const alphaRoutes = [];
		Object.keys(shuttle_routes)
			.sort((a, b) => shuttle_routes[a].name.trim().localeCompare(shuttle_routes[b].name.trim()))
				.forEach((key) => {
					alphaRoutes.push(shuttle_routes[key]);
				});
		Actions.ShuttleRoutesListView({ shuttle_routes: alphaRoutes, gotoStopsList: this.gotoStopsList });
	}

	gotoStopsList = (stops) => {
		// Sort stops by alphabet
		const alphaStops = [];
		Object.keys(stops)
			.sort((a, b) => stops[a].name.trim().localeCompare(stops[b].name.trim()))
				.forEach((key) => {
					alphaStops.push(stops[key]);
				});

		Actions.ShuttleStopsListView({ shuttle_stops: alphaStops, addStop: this.addStop });
	}

	gotoSavedList = () => {
		Actions.ShuttleSavedListView();
	}

	addStop = (stopID) => {
		Toast.show('Stop added.');
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
		removeStop: (stopIndex) => {
			dispatch({ type: 'REMOVE_STOP', stopIndex });
		}
	};
}

const ActualShuttleCard = connect(
	mapStateToProps,
	mapDispatchtoProps
)(ShuttleCardContainer);

export default ActualShuttleCard;
