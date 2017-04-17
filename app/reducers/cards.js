// NOTE: AppSettings.XX_CARD_ENABLED is being deprecated to pave the way for more dynamic cards

const initialState = {
	cards: {
		weather: 		{ id: 'weather', active: true, name: 'Weather', component: 'WeatherCard' },
		shuttle: 		{ id: 'shuttle', active: true, name: 'Shuttle', component: 'ShuttleCard' },
		dining: 		{ id: 'dining', active: true, name: 'Dining', component: 'DiningCard' },
		events: 		{ id: 'events', active: true, name: 'Events', component: 'EventsCard' },
		quicklinks: 	{ id: 'quicklinks', active: true, name: 'Links', component: 'QuicklinksCard' },
		news: 		{ id: 'news', active: true, name: 'News', component: 'NewsCard' },
	},
	cardOrder: ['weather', 'shuttle', 'dining', 'events', 'quicklinks', 'news'],
	// 'map': 			{ active: true, order: 7, name: 'Map', component: 'SearchCard' }
};

function cards(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_CARD_STATE':
		newState.cards[action.id] = Object.assign({}, newState.cards[action.id], { active: action.active });

		return newState;
	case 'SHOW_CARD': {
		if (newState.cards[action.id] && !newState.cards[action.id].active) {
			newState.cards[action.id] = Object.assign({}, newState.cards[action.id], { active: true });
		}
		return newState;
	}
	case 'HIDE_CARD':
		if (newState.cards[action.id] && newState.cards[action.id].active) {
			newState.cards[action.id] = Object.assign({}, newState.cards[action.id], { active: false });
		}
		return newState;
	case 'SET_CARD_ORDER':
		newState.cardOrder = action.cardOrder.slice();

		return newState;
	}
	return state;
}

module.exports = cards;
