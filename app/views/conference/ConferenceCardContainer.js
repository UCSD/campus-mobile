import React from 'react';

import { connect } from 'react-redux';

import ConferenceCard from './ConferenceCard';
import logger from '../../util/logger';

const ConferenceCardContainer = ({ conferenceData, saved, hideCard }) => {
	logger.ga('Card Mounted: Conference');
	if (conferenceData) {
		return (
			<ConferenceCard
				title="Events"
				conference={conferenceData}
				saved={saved}
				hideCard={hideCard}
			/>
		);
	} else {
		return null;
	}
};

const mapStateToProps = (state) => (
	{
		conferenceData: state.conference.data,
		saved: state.conference.saved
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		hideCard: (id) => {
			dispatch({ type: 'UPDATE_CARD_STATE', id, state: false });
		}
	}
);

const ActualConferenceCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(ConferenceCardContainer);

export default ActualConferenceCard;
