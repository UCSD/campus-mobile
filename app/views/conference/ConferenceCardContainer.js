import React from 'react';

import { connect } from 'react-redux';

import CardComponent from '../card/CardComponent';
import ConferenceCard from './ConferenceCard';
import logger from '../../util/logger';
import { hideCard } from '../../actions/cards';

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
					hideCard={this.props.hideCard}
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
	{
		hideCard: (id) => {
			dispatch(hideCard(id));
		}
	}
);

const ActualConferenceCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(ConferenceCardContainer);

export default ActualConferenceCard;
