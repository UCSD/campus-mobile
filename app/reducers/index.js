import { combineReducers } from 'redux';

import cardsReducer from './cards';
import locationReducer from './location';
import shuttleReducer from './shuttle';
import mapReducer from './map';
import userReducer from './user';
import weatherReducer from './weather';
import surfReducer from './surf';
import diningReducer from './dining';
import eventsReducer from './events';
import newsReducer from './news';
import linksReducer from './links';
import surveyReducer from './survey';
import specialEventsReducer from './specialEvents';
import feedbackReducer from './feedback';
import homeReducer from './home';

module.exports = combineReducers({
	cards: cardsReducer,
	location: locationReducer,
	shuttle: shuttleReducer,
	map: mapReducer,
	user: userReducer,
	weather: weatherReducer,
	surf: surfReducer,
	dining: diningReducer,
	events: eventsReducer,
	news: newsReducer,
	links: linksReducer,
	survey: surveyReducer,
	specialEvents: specialEventsReducer,
	feedback: feedbackReducer,
	home: homeReducer,
});
