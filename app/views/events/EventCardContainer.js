import React from 'react';

import { connect } from 'react-redux';
import moment from 'moment';

import DataListCard from '../common/DataListCard';
import logger from '../../util/logger';
import { militaryToAMPM } from '../../util/general';

const EventCardContainer = ({ eventsData }) => {
	logger.ga('Card Mounted: Events');

	if (eventsData) {
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
};

const mapStateToProps = (state) => (
	{
		eventsData: state.events.data,
	}
);

const ActualEventCard = connect(
	mapStateToProps
)(EventCardContainer);

export default ActualEventCard;
