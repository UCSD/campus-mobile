import React from 'react';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

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
		const { stopsData, locationPermission, savedStops, removeStop, closestStop } = this.props;

		const displayStops = savedStops.slice();
		if (closestStop) {
			displayStops.unshift(closestStop);
		}

		return (<ShuttleCard
			savedStops={displayStops}
			stopsData={stopsData}
			permission={locationPermission}
			gotoSavedList={this.gotoSavedList}
			gotoRoutesList={this.gotoRoutesList}
			removeStop={removeStop}
			closestStop={closestStop}
		/>);
	}

	gotoRoutesList = () => {
		const { shuttle_routes } = this.props;
		Actions.ShuttleRoutesListView({ shuttle_routes, gotoStopsList: this.gotoStopsList });
	}

	gotoStopsList = (stops) => {
		Actions.ShuttleStopsListView({ shuttle_stops: stops, addStop: this.addStop });
	}

	gotoSavedList = () => {
		Actions.ShuttleSavedListView();
	}

	addStop = (stopID) => {
		this.props.addStop(stopID); // dispatch saga
		Actions.popTo('Home'); // pop back to home
	}
}

function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		locationPermission: state.location.permission,
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
