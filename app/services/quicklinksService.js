const AppSettings = require('../AppSettings');

const QuicklinksService = {
	FetchQuicklinks() {
		return fetch(AppSettings.QUICKLINKS_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
};

export default QuicklinksService;
