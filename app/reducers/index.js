import { combineReducers } from 'redux';

import cardsReducer from './cards';
import locationReducer from './location';
import shuttleReducer from './shuttle';
import mapReducer from './map';
import userReducer from './user';

module.exports = combineReducers({
	cards: cardsReducer,
	location: locationReducer,
	shuttle: shuttleReducer,
	map: mapReducer,
	user: userReducer,
});
