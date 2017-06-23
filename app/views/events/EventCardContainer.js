import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import moment from 'moment';

import DataListCard from '../common/DataListCard';
import logger from '../../util/logger';
import { militaryToAMPM } from '../../util/general';

const EventCardContainer = ({ eventsData }) => {
	logger.ga('Card Mounted: Events');

	let data = null;
	if (Array.isArray(eventsData)) {
		eventsData.forEach((element) => {
			element.subtext = moment(element.eventdate).format('MMM Do') + ', ' + militaryToAMPM(element.starttime) + ' - ' + militaryToAMPM(element.endtime);
			element.image = element.imagethumb;
		});
		data = eventsData;
	}
	return (
		<DataListCard
			id="events"
			title="Events"
			data={data}
			item={'EventItem'}
		/>
	);
};

EventCardContainer.propTypes = {
	eventsData: PropTypes.array
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
