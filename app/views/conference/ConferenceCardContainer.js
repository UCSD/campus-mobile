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
		return (
			<ConferenceCard
				title="Events"
				schedule={this.props.scheduleData}
				saved={this.props.saved}
				add={this.props.addConference}
				remove={this.props.removeConference}
			/>
		);
	}
}

const mapStateToProps = (state) => (
	{
		scheduleData: state.conference.data,
		saved: state.conference.saved
	}
);

const mapDispatchToProps = (dispatch) => (
	{
		addConference: (id) => {
			dispatch({ type: 'ADD_CONFERENCE', id });
		},
		removeConference: (id) => {
			dispatch({ type: 'REMOVE_CONFERENCE', id });
		}
	}
);

const ActualConferenceCard = connect(
	mapStateToProps,
	mapDispatchToProps
)(ConferenceCardContainer);

export default ActualConferenceCard;
