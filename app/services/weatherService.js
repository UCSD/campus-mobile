const AppSettings = require('../AppSettings');

const WeatherService = {
	FetchWeather() {
		return fetch(AppSettings.WEATHER_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json());
	},

	FetchSurf() {
		return fetch(AppSettings.SURF_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then(response => response.json());
	},
};

export default WeatherService;
