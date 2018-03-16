import React from 'react';

import { connect } from 'react-redux';

import DataListCard from '../common/DataListCard';
import CardComponent from '../card/CardComponent';

const logger = require('../../util/logger');

export class DiningCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Dining');
	}

	render() {
		const { diningData } = this.props;
		// todo: use location permission
		return (
			<DataListCard
				id="dining"
				title="Dining"
				data={diningData}
				item={'DiningItem'}
			/>
		);
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
