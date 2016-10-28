const AppSettings = require('../AppSettings');

const WelcomeWeekService = {
	FetchEvents() {
		return fetch(AppSettings.WELCOME_WEEK_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
};

export default WelcomeWeekService;
