import { combineReducers } from 'redux';

import cardsReducer from './cards';
import locationReducer from './location';

module.exports = combineReducers({
	cards: cardsReducer,
	location: locationReducer
});
