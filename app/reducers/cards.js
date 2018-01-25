const initialState = {
	cards: {
		specialEvents: 	{ id: 'specialEvents', active: false, autoActivated: false, name: 'Special Events', component: 'SpecialEventsCard' },
		schedule: 		{ id: 'schedule', active: true, name: 'Class Schedule', component: 'ScheduleCard' },
		weather: 		{ id: 'weather', active: true, name: 'Weather', component: 'WeatherCard' },
		shuttle: 		{ id: 'shuttle', active: true, name: 'Shuttle', component: 'ShuttleCard' },
		dining: 		{ id: 'dining', active: true, name: 'Dining', component: 'DiningCard' },
		events: 		{ id: 'events', active: true, name: 'Events', component: 'EventsCard' },
		quicklinks: 	{ id: 'quicklinks', active: true, name: 'Links', component: 'QuicklinksCard' },
		news: 			{ id: 'news', active: true, name: 'News', component: 'NewsCard' },
	},
	cardOrder: ['specialEvents', 'schedule', 'weather',  'shuttle', 'dining', 'events', 'quicklinks', 'news'],
};

function cards(state = initialState, action) {
	var newState = { ...state };

	switch (action.type) {
		case 'SET_CARD_STATE':
			return {
				...state,
				cards: {
					...state.cards,
					[action.id]: { ...state.cards[action.id], active: action.active }
				}
			};
		case 'SET_AUTOACTIVATED_STATE':
			newState.cards[action.id] = Object.assign({}, newState.cards[action.id], { autoActivated: action.autoActivated });

			return newState;
		case 'SHOW_CARD': {
			if (newState.cards[action.id] && !newState.cards[action.id].active) {
				return {
					...state,
					cards: {
						...state.cards,
						[action.id]: { ...state.cards[action.id], active: true }
					}
				};
			}
			return newState;
		}
		case 'HIDE_CARD':
			if (newState.cards[action.id] && newState.cards[action.id].active) {
				return {
					...state,
					cards: {
						...state.cards,
						[action.id]: { ...state.cards[action.id], active: false }
					}
				};
			}
			return newState;
		case 'SET_CARD_ORDER':
			newState.cardOrder = action.cardOrder.slice();

			return newState;
	}

	return state;
}

module.exports = cards;
