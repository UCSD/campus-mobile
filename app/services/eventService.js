var AppSettings = 		require('../AppSettings');


var EventService = {

  FetchEvents: function() {
    return fetch(AppSettings.EVENTS_API_URL, {
       headers: {
         'Cache-Control': 'no-cache'
       }
     })
     .then((response) => response.json());
  }

}

export default EventService;
