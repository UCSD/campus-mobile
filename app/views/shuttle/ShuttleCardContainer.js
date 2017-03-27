import React from 'react';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import { updateMaster } from '../../actions/shuttle';
import CardComponent from '../card/CardComponent';
import ShuttleCard from './ShuttleCard';

const logger = require('../../util/logger');

class ShuttleCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Shuttle');
		this.props.updateMaster();
	}

	render() {
		const { closestStop, stopData, locationPermission } = this.props;

		return (<ShuttleCard
			stopData={stopData}
			permission={locationPermission}
			gotoShuttleStop={this.gotoShuttleStop}
			stopID={closestStop}
		/>);
	}

	gotoShuttleStop = (stopID) => {
		Actions.ShuttleStop({ stopID });
	}
}

function mapStateToProps(state, props) {
	return {
		location: state.location.position,
		locationPermission: state.location.permission,
		closestStop: state.shuttle.closestStop,
		stopData: state.shuttle.stops,
		arrivalData: (state.shuttle.closestStop !== -1) ? (state.shuttle.stops[state.shuttle.closestStop].arrivals) : (null),
	};
}

function mapDispatchtoProps(dispatch) {
	return {
		updateMaster: () => {
			dispatch(updateMaster());
		}
	};
}

const ActualShuttleCard = connect(
	mapStateToProps,
	mapDispatchtoProps
)(ShuttleCardContainer);

export default ActualShuttleCard;
