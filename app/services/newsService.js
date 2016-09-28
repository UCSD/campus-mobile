var AppSettings = 		require('../AppSettings');


var NewsService = {

  FetchNews: function() {
    return fetch(AppSettings.NEWS_API_URL, {
       headers: {
         'Cache-Control': 'no-cache'
       }
     })
     .then((response) => response.json());
  }

}

export default NewsService;
