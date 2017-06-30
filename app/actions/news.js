import logger from '../util/logger';
import NewsService from '../services/newsService';
import { NEWS_API_TTL } from '../AppSettings';

function updateNews() {
	return (dispatch, getState) => {
		const { lastUpdated, data } = getState().news;
		const nowTime = new Date().getTime();
		const timeDiff = nowTime - lastUpdated;
		const newsTTL = NEWS_API_TTL;

		if (timeDiff < newsTTL && data) {
			// Do nothing, no need to fetch new data
		} else {
			// Fetch for new data
			NewsService.FetchNews()
				.then((news) => {
					if (news) {
						dispatch({
							type: 'SET_NEWS_UPDATE',
							nowTime
						});
						dispatch({
							type: 'SET_NEWS',
							news
						});
					}
				})
				.catch((error) => {
					logger.log('Error fetching news: ' + error);
					return null;
				});
		}
	};
}

module.exports = {
	updateNews
};
