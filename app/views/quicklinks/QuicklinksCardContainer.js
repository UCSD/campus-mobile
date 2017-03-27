import React from 'react';
import {
	AppState,
} from 'react-native';

import { connect } from 'react-redux';

import CardComponent from '../card/CardComponent';
import { updateLinks } from '../../actions/links';
import QuicklinksCard from './QuicklinksCard';
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
			<QuicklinksCard
				data={this.props.linksData}
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
