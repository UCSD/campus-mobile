import logger from '../util/logger';
import LinksService from '../services/quicklinksService';
import { QUICKLINKS_API_TTL } from '../AppSettings';

function updateLinks() {
	return (dispatch, getState) => {
		const { lastUpdated, data } = getState().links;
		const nowTime = new Date().getTime();
		const timeDiff = nowTime - lastUpdated;
		const linksTTL = QUICKLINKS_API_TTL * 1000;

		if ((timeDiff < linksTTL) && data) {
			// Do nothing, no need to fetch new data
		} else {
			// Fetch for new data
			LinksService.FetchQuicklinks()
				.then((links) => {
					if (links) {
						dispatch({
							type: 'SET_LINKS_UPDATE',
							nowTime
						});
						dispatch({
							type: 'SET_LINKS',
							links
						});
					}
				})
				.catch((error) => {
					logger.log('Error fetching links: ' + error);
					return null;
				});
		}
	};
}

module.exports = {
	updateLinks
};
