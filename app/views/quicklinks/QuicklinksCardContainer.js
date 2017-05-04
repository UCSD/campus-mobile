import React from 'react';
import { connect } from 'react-redux';

import DataListCard from '../common/DataListCard';
import CardComponent from '../card/CardComponent';
import general from '../../util/general';
import logger from '../../util/logger';

class QuicklinksCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Quicklinks');
	}

	render() {
		return (
			<DataListCard
				title="Links"
				data={this.props.linksData}
				rows={4}
				item={'QuicklinksItem'}
				cardSort={general.dynamicSort('card-order')}
			/>
		);
	}
}

const mapStateToProps = (state) => (
	{
		linksData: state.links.data,
	}
);

const ActualLinksCard = connect(
	mapStateToProps
)(QuicklinksCardContainer);

export default ActualLinksCard;
