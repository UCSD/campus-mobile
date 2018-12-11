const AppSettings = require('../AppSettings')
const Entities = require('html-entities').AllHtmlEntities

const entities = new Entities()

const NewsService = {
	FetchNews() {
		return fetch(AppSettings.NEWS_API_URL, {
			headers: { 'Cache-Control': 'no-cache' }
		})
			.then(response => (response.json())
				.then((news) => {
					if (Array.isArray(news.items)) {
						for (let i = 0; news.items.length > i; i++) {
							// Perform this on the feed level when possible
							news.items[i].title = entities.decode(news.items[i].title)

							if (news.items[i].image) {
								const image_lg = news.items[i].image.replace(/_teaser\./,'.')
								image_lg.replace(/-thumb/g,'')
								if (image_lg.length > 10) {
									news.items[i].image_lg = image_lg
								}
							}
						}
						return news.items
					} else {
						return null
					}
				}))
			.catch((err) => {
				console.log('Error fetching news' + err)
				return null
			})
	}
}

export default NewsService
