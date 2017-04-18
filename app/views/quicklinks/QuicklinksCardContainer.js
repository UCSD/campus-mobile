import React from 'react';
import {
	AppState,
} from 'react-native';

import { connect } from 'react-redux';

import DataListCard from '../common/DataListCard';
import CardComponent from '../card/CardComponent';
import { updateLinks } from '../../actions/links';
import general from '../../util/general';
import logger from '../../util/logger';

class QuicklinksCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Quicklinks');

		this.props.updateLinks();
		AppState.addEventListener('change', this._handleAppStateChange);
	}

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	}

	_handleAppStateChange = (currentAppState) => {
		this.setState({ currentAppState });
		this.props.updateLinks();
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

const mapDispatchToProps = (dispatch) => (
	{
		updateLinks: () => {
			dispatch(updateLinks());
		}
	}
);

const ActualLinksCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(QuicklinksCardContainer);

export default ActualLinksCard;
