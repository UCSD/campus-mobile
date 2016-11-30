// NOTE: AppSettings.XX_CARD_ENABLED is being deprecated to pave the way for more dynamic cards

var initialState = {
	'weather': 		{ active: true, order: 1, name: 'Weather' },
	'shuttle': 		{ active: true, order: 2, name: 'Shuttle' },
	'dining': 		{ active: true, order: 3, name: 'Dining' },
	'events': 		{ active: true, order: 4, name: 'Events' },
	'quicklinks': 	{ active: true, order: 5, name: 'Quick Links' },
	'news': 		{ active: true, order: 6, name: 'News' },
	'map': 			{ active: true, order: 7, name: 'Map' }
};

function cards(state = initialState, action) {

	switch (action.type) {
		case 'SHOW_CARD':
			var newState = {...state};
			if (!newState[action.id].active)
				newState[action.id].active = true;
			return newState[action.id].active;

		case 'HIDE_CARD':
			var newState = {...state};
			if (newState[action.id].active)
				newState[action.id].active = false;
			return newState[action.id].active;

		case 'ADD_CARD':
			var newState = {...state};
			// check for duplicate, early exit
			if (newState[action.id])
				return newState;

			newState[action.id] = true;
			return newState;

		case 'DELETE_CARD':
			var newState = {...state};
			delete newState[action.id];
			return newState;
	}
	return state;

}

module.exports = cards
