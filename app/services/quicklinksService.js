var AppSettings = require('../AppSettings');

var QuicklinksService = {
	FetchQuicklinks: function() {
		return fetch(AppSettings.QUICKLINKS_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	}
}

export default QuicklinksService;