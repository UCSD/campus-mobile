// NOTE: AppSettings.XX_CARD_ENABLED is being deprecated to pave the way for more dynamic cards

const initialState = {
	'weather': 		{ active: true, order: 1, name: 'Weather', component: 'WeatherCard' },
	'shuttle': 		{ active: true, order: 2, name: 'Shuttle', component: 'ShuttleCard' },
	'dining': 		{ active: true, order: 3, name: 'Dining', component: 'DiningCard' },
	'events': 		{ active: true, order: 4, name: 'Events', component: 'EventsCard' },
	'quicklinks': 	{ active: true, order: 5, name: 'Links', component: 'QuicklinksCard' },
	'news': 		{ active: true, order: 6, name: 'News', component: 'NewsCard' },
	// 'map': 			{ active: true, order: 7, name: 'Map', component: 'SearchCard' }
};

function cards(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SHOW_CARD': {
		if (newState[action.id] && !newState[action.id].active) {
			newState[action.id].active = true;
		}
		return newState;
	}
	case 'HIDE_CARD':
		if (newState[action.id] && newState[action.id].active) {
			newState[action.id].active = false;
		}
		return newState;
	case 'ADD_CARD':
		// check for duplicate, early exit
		if (newState[action.id]) {
			return newState;
		}

		newState[action.id] = true;
		return newState;
	case 'DELETE_CARD':
		delete newState[action.id];
		return newState;
	}
	return state;
}

module.exports = cards;
