import { getTimestampNumeric } from '../util/general';

const AppSettings = require('../AppSettings');
const dateFormat = require('dateformat');

const WeatherService = {

	// Powered by Dark Sky API
	/*
		Expected weatherData JSON
		{
			currently: {
				temperature,
				summary,
				icon
			}
			daily: {
				dayofweek,
				icon,
				tempMax,
				tempMin
			}
		}
	*/
	FetchWeather() {
		return fetch(AppSettings.WEATHER_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then((response) => response.json())
		// This part should be on lambda...
		.then((responseData) => {
			responseData.currently.temperature = Math.round(responseData.currently.temperature);
			responseData.daily.data = responseData.daily.data.slice(0,5);

			for (let i = 0; responseData.daily.data.length > i; i++) {
				const data = responseData.daily.data[i];
				const wf_date = new Date(data.time * 1000);
				const wf_days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
				const wf_day = wf_date.getDay();

				data.dayofweek = wf_days[wf_day];
				data.tempMax = Math.round(data.temperatureMax);
				data.tempMin = Math.round(data.temperatureMin);
			}

			return responseData;
		});
	},

	FetchSurf() {
		return fetch(AppSettings.SURF_API_URL, {
			headers: {
				'Cache-Control': 'no-cache'
			}
		})
		.then(response => response.json())

		// Should also be on lambda
		.then((surfData) => {
			const surfDataArray = [];

			for (let i = 0; surfData.length > i; i++) {
				const surfDataRow = surfData[i];

				const surfDataRowObj = {};

				surfDataRowObj.surfTitle = surfDataRow.title.replace(/ : .*/g, '');
				surfDataRowObj.surfHeight = surfDataRow.title
					.replace(/.* : /g, '')
					.replace(/ft.*/g, '')
					.replace(/^\./g, '').replace(/^ /g, '')
					.replace(/ $/g, '')
					.replace(/Surf: /g, '') + ' ft';
				surfDataRowObj.surfDesc = surfDataRow.title
					.replace(/.*ft/g, '')
					.replace(/^\./g, '')
					.replace(/ \+ - /g, '')
					.replace(/\+ - /g, '')
					.replace(/^ /g, '')
					.replace(/ $/g, '')
					.replace(/^- /g, '');
				// surfDataRowObj.surfDesc = this.capitalizeFirstLetter(surfDataRowObj.surfDesc);

				surfDataRowObj.surfDate = surfDataRow.date.replace(/ PDT/g, '');
				surfDataRowObj.surfTimestamp = dateFormat(surfDataRowObj.surfDate, 'isoDateTime');
				surfDataRowObj.surfTimestampNumeric = surfDataRowObj.surfTimestamp.substring(0,10).replace(/-/g, '');
				surfDataRowObj.surfDayOfWeek = dateFormat(surfDataRowObj.surfDate, 'ddd').toUpperCase();
				surfDataRowObj.surfDayOfMonth = dateFormat(surfDataRowObj.surfDate, 'd');
				surfDataRowObj.surfMonth = dateFormat(surfDataRowObj.surfDate, 'mmm');

				// Only care about surf data that's new
				if (surfDataRowObj.surfTimestampNumeric >= getTimestampNumeric()) {
					surfDataArray.push(surfDataRowObj);
				}
			}

			// If no results for today, set surfDataNoResults true, and display a message
			if (surfDataArray.length === 0) {
				return null;
			} else {
				// Sort the result rows so we can break different days into groups
				surfDataArray.sort((a, b) => {
					if (a.surfTimestampNumeric < b.surfTimestampNumeric) {
						return -1;
					} else if (a.surfTimestampNumeric > b.surfTimestampNumeric) {
						return 1;
					} else {
						return 0;
					}
				});
				return surfDataArray;
			}
		});
	},
};

export default WeatherService;
