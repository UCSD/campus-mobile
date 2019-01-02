const AppSettings = require('../AppSettings')

const WeatherService = {

	FetchWeather() {
		return fetch(AppSettings.WEATHER_API_URL)
			.then(response => response.json())
			.then((responseData) => {
				if (Array.isArray(responseData.daily.data)) {
					responseData.currently.temperature = Math.round(responseData.currently.temperature)
					responseData.daily.data = responseData.daily.data.slice(0,5)

					for (let i = 0; responseData.daily.data.length > i; i++) {
						const data = responseData.daily.data[i]
						const wf_date = new Date(data.time * 1000)
						const wf_days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
						const wf_day = wf_date.getDay()

						data.dayofweek = wf_days[wf_day]
						data.tempMax = Math.round(data.temperatureMax)
						data.tempMin = Math.round(data.temperatureMin)
					}

					return responseData
				} else {
					return null
				}
			})
			.catch((err) => {
				console.log('Error fetching weather: ' + err)
				return null
			})
	},

	FetchSurf() {
		return fetch(AppSettings.SURF_API_URL)
			.then(response => response.json())
			.then(responseData => responseData)
			.catch((err) => {
				console.log('Error fetching surf: ' + err)
				return null
			})
	},
}

export default WeatherService
