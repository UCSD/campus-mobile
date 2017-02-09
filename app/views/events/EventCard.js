import React from 'react';
import {
	AppState,
	View,
	Text,
	TouchableHighlight
} from 'react-native';

import { Actions } from 'react-native-router-flux';
import { connect } from 'react-redux';

import Card from '../card/Card';
import CardComponent from '../card/CardComponent';
import { updateEvents } from '../../actions/events';
import EventList from './EventList';
import logger from '../../util/logger';
import css from '../../styles/css';

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

const EventCard = ({ data }) => (
	<Card id="events" title="Events">
		<View style={css.events_list}>
			{data ? (
				<View>
					<EventList
						data={data}
						rows={3}
						scrollEnabled={false}
					/>
					<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => Actions.EventListView({ data })}>
						<View style={css.events_more}>
							<Text style={css.events_more_label}>View All Events</Text>
						</View>
					</TouchableHighlight>
				</View>
			) : (
				<View style={[css.flexcenter, css.pad40]}>
					<Text>There was a problem loading events, try back soon.</Text>
				</View>
			)}
		</View>
	</Card>
);
