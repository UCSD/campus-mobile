import React from 'react';
import { connect } from 'react-redux';

import DataListCard from '../common/DataListCard';

const logger = require('../../util/logger');

const DiningCardContainer = ({ diningData }) => {
	logger.ga('Card Mounted: Dining');

	// todo: use location permission
	return (
		<DataListCard
			id="dining"
			title="Dining"
			data={diningData}
			item={'DiningItem'}
		/>
	);
};


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
