import React, { PropTypes } from 'react';
import {
	AppState,
} from 'react-native';

import { connect } from 'react-redux';
import moment from 'moment';

import CardComponent from '../card/CardComponent';
import { updateEvents } from '../../actions/events';
import DataListCard from '../common/DataListCard';
import logger from '../../util/logger';
import { militaryToAMPM } from '../../util/general';

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
		const { eventsData } = this.props;
		if (Array.isArray(eventsData)) {
			eventsData.forEach((element) => {
				element.subtext = moment(element.eventdate).format('MMM Do') + ', ' + militaryToAMPM(element.starttime) + ' - ' + militaryToAMPM(element.endtime);
				element.image = element.imagethumb;
			});
		}

		return (
			<DataListCard
				id="events"
				title="Events"
				data={eventsData}
				item={'EventItem'}
			/>
		);
	}
}

EventCardContainer.propTypes = {
	eventsData: PropTypes.array
};

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
