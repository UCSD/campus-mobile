var AppSettings = 		require('../AppSettings');


var TopStoriesService = {

  FetchTopStories: function() {
    return fetch(AppSettings.TOP_STORIES_API_URL, {
       headers: {
         'Cache-Control': 'no-cache'
       }
     })
     .then((response) => response.json());
  }

}

export default TopStoriesService;
