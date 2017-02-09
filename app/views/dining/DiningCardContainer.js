import React from 'react';

import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';

import CardComponent from '../card/CardComponent';
import DiningCard from './DiningCard';

const logger = require('../../util/logger');

class DiningCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Dining');
	}

	render() {
		const { diningData, locationPermission } = this.props;

		return (
			<DiningCard
				data={diningData}
				rows={4}
				permission={locationPermission}
			/>
		);
	}

	gotoDiningListView = () => {
		Actions.DiningListView({ data: this.props.diningData });
	}
}

function mapStateToProps(state, props) {
	return {
		diningData: state.dining.data,
		locationPermission: state.location.permission,
	};
}

const ActualDiningCard = connect(
	mapStateToProps,
)(DiningCardContainer);

export default ActualDiningCard;
