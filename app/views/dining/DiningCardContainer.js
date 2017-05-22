import React from 'react';
import { connect } from 'react-redux';

import DataListCard from '../common/DataListCard';
import logger from '../../util/logger';

const DiningCardContainer = ({ diningData }) => {
	logger.ga('Card Mounted: Dining');
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
	};
}

const ActualDiningCard = connect(
	mapStateToProps,
)(DiningCardContainer);

export default ActualDiningCard;
