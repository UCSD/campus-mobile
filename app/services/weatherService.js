var AppSettings = 		require('../AppSettings');


var WeatherService = {

  FetchWeather: function() {
    return fetch(AppSettings.WEATHER_API_URL, {
       headers: {
         'Cache-Control': 'no-cache'
       }
     })
     .then((response) => response.json());
  }

}

export default WeatherService;
