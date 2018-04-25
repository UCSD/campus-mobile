const initialState = {
	cards: {
		specialEvents: {
			id: 'specialEvents',
			active: false,
			autoActivated: false,
			name: 'Special Events',
			component: 'SpecialEventsCard',
			defaultPosition: 0
		},
		finals: {
			id: 'finals',
			active: true,
			name: 'Finals Schedule',
			component: 'FinalsCard',
			authenticated: true,
			classifications: { student: true },
			defaultPosition: 1
		},
		schedule: {
			id: 'schedule',
			active: true,
			name: 'Class Schedule',
			component: 'ScheduleCard',
			authenticated: true,
			classifications: { student: true },
			defaultPosition: 2
		},
		shuttle: {
			id: 'shuttle',
			active: true,
			name: 'Shuttle',
			component: 'ShuttleCard',
			defaultPosition: 3
		},
		dining: {
			id: 'dining',
			active: true,
			name: 'Dining',
			component: 'DiningCard',
			defaultPosition: 4
		},
		events: {
			id: 'events',
			active: true,
			name: 'Events',
			component: 'EventsCard',
			defaultPosition: 5
		},
		news: {
			id: 'news',
			active: true,
			name: 'News',
			component: 'NewsCard',
			defaultPosition: 6
		},
		quicklinks: {
			id: 'quicklinks',
			active: true,
			name: 'Links',
			component: 'QuicklinksCard',
			defaultPosition: 7
		},
		weather: {
			id: 'weather',
			active: true,
			name: 'Weather',
			component: 'WeatherCard',
			defaultPosition: 8
		}
	},

	// Only cards that show up by default
	// on first launch should appear here.
	cardOrder: [
		'shuttle',
		'dining',
		'events',
		'news',
		'quicklinks',
		'weather'
	],
}

function cards(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
	case 'SET_CARD_STATE':
		return {
			...state,
			cards: {
				...state.cards,
				[action.id]: { ...state.cards[action.id], active: action.active }
			}
		}
	case 'SET_AUTOACTIVATED_STATE':
		newState.cards[action.id] = Object.assign({}, newState.cards[action.id], { autoActivated: action.autoActivated })

		return newState
	case 'SET_CARD_ORDER':
		newState.cardOrder = action.cardOrder.slice()

		return newState
	}

	return state
}

module.exports = cards
