import React from 'react';
import {
	AppState,
} from 'react-native';

import { connect } from 'react-redux';

import CardComponent from '../card/CardComponent';
import { updateEvents } from '../../actions/events';
import EventCard from './EventCard';
import logger from '../../util/logger';

class EventCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Events');

		this.props.updateEvents();
		AppState.addEventListener('change', this._handleAppStateChange);
	}

	componentWillUnmount() {
		AppState.removeEventListener('change', this._handleAppStateChange);
	}

	_handleAppStateChange = (currentAppState) => {
		this.setState({ currentAppState });
		this.props.updateEvents();
	}

	render() {
		return (
			<EventCard
				data={this.props.eventsData}
			/>
		);
	}
}

const mapStateToProps = (state) => (
	{
		eventsData: state.events.data,
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		updateEvents: () => {
			dispatch(updateEvents());
		}
	}
);

const ActualEventCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(EventCardContainer);

export default ActualEventCard;