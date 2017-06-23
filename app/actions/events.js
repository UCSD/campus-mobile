import logger from '../util/logger';
import EventService from '../services/eventService';
import { EVENTS_API_TTL } from '../AppSettings';

function updateEvents() {
	return (dispatch, getState) => {
		const { lastUpdated, data } = getState().events;
		const nowTime = new Date().getTime();
		const timeDiff = nowTime - lastUpdated;
		const eventsTTL = EVENTS_API_TTL * 1000;

		if (timeDiff < eventsTTL && data) {
			// Do nothing, no need to fetch new data
		} else {
			// Fetch for new data
			EventService.FetchEvents()
				.then((events) => {
					if (events) {
						dispatch({
							type: 'SET_EVENTS_UPDATE',
							nowTime
						});
						dispatch({
							type: 'SET_EVENTS',
							events
						});
					}
				})
				.catch((error) => {
					logger.log('Error fetching events: ' + error);
					return null;
				});
		}
	};
}

module.exports = {
	updateEvents
};
