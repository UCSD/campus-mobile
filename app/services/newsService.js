const AppSettings = require('../AppSettings');

const NewsService = {
	FetchNews() {
		return fetch(AppSettings.NEWS_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
};

export default NewsService;
