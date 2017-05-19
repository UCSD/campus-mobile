import React from 'react';
import { connect } from 'react-redux';

import DataListCard from '../common/DataListCard';
import general from '../../util/general';
import logger from '../../util/logger';

const QuicklinksCardContainer = ({ linksData }) => {
	logger.ga('Card Mounted: Quicklinks');
	return (
		<DataListCard
			title="Links"
			data={linksData}
			rows={4}
			item={'QuicklinksItem'}
			cardSort={general.dynamicSort('card-order')}
		/>
	);
};

const mapStateToProps = (state) => (
	{
		linksData: state.links.data,
	}
);

const ActualLinksCard = connect(
	mapStateToProps
)(QuicklinksCardContainer);

export default ActualLinksCard;
