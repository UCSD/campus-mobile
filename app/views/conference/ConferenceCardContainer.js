import React from 'react';

import { connect } from 'react-redux';

import CardComponent from '../card/CardComponent';
import ConferenceCard from './ConferenceCard';
import logger from '../../util/logger';

class ConferenceCardContainer extends CardComponent {
	componentDidMount() {
		logger.ga('Card Mounted: Conference');
	}

	render() {
		if (this.props.conferenceData) {
			return (
				<ConferenceCard
					title="Events"
					conference={this.props.conferenceData}
					saved={this.props.saved}
				/>
			);
		} else {
			return null;
		}
	}
}

const mapStateToProps = (state) => (
	{
		conferenceData: state.conference.data,
		saved: state.conference.saved
	}
);

const mapDispatchToProps = (dispatch) => (
	{}
);

const ActualConferenceCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(ConferenceCardContainer);

export default ActualConferenceCard;
