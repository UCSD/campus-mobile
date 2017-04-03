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
		const { stopsData, locationPermission, savedStops } = this.props;

		return (<ShuttleCard
			savedStops={savedStops}
			stopsData={stopsData}
			permission={locationPermission}
			gotoSavedList={this.gotoSavedList}
			gotoRoutesList={this.gotoRoutesList}
			removeStop={this.props.removeStop}
			moveStopUp={this.props.moveStopUp}
			moveStopDown={this.props.moveStopDown}
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
		const { savedStops } = this.props;
		Actions.ShuttleSavedListView({ savedStops });
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
		arrivalData: (state.shuttle.closestStop !== -1) ? (state.shuttle.stops[state.shuttle.closestStop].arrivals) : (null),
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
		},
		moveStopUp: (stopIndex) => {
			dispatch({ type: 'MOVE_STOP_UP' });
		},
		moveStopDown: (stopIndex) => {
			dispatch({ type: 'MOVE_STOP_DOWN' });
		}
	};
}

const ActualShuttleCard = connect(
	mapStateToProps,
	mapDispatchtoProps
)(ShuttleCardContainer);

export default ActualShuttleCard;
