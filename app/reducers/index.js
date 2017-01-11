import { combineReducers } from 'redux';

import cardsReducer from './cards';
import locationReducer from './location';
import userReducer from './user';

module.exports = combineReducers({
	cards: cardsReducer,
	location: locationReducer,
	user: userReducer,
});
