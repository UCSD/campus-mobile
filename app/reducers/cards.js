const initialState = {
	cards: {
		specialEvents: {
			id: 'specialEvents',
			active: false,
			autoActivated: false,
			name: 'Special Events',
			component: 'SpecialEventsCard'
		},
		finals: {
			id: 'finals',
			active: true,
			name: 'Finals Schedule',
			component: 'FinalsCard',
			authenticated: true,
			classifications: { student: true }
		},
		schedule: {
			id: 'schedule',
			active: true,
			name: 'Class Schedule',
			component: 'ScheduleCard',
			authenticated: true,
			classifications: { student: true }
		},
		shuttle: {
			id: 'shuttle',
			active: true,
			name: 'Shuttle',
			component: 'ShuttleCard'
		},
		dining: {
			id: 'dining',
			active: true,
			name: 'Dining',
			component: 'DiningCard'
		},
		events: {
			id: 'events',
			active: true,
			name: 'Events',
			component: 'EventsCard'
		},
		news: {
			id: 'news',
			active: true,
			name: 'News',
			component: 'NewsCard',
		},
		quicklinks: {
			id: 'quicklinks',
			active: true,
			name: 'Links',
			component: 'QuicklinksCard'
		},
		weather: {
			id: 'weather',
			active: true,
			name: 'Weather',
			component: 'WeatherCard'
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
		case 'INSERT_CARD': {
			const { id, position } = action
			const newOrder = newState.cardOrder.slice()
			newOrder.splice(position, 0, id)
			newState.cardOrder = newOrder
			return newState
		}
		case 'REMOVE_CARD': {
			const { id } = action
			const position = state.cardOrder.indexOf(id)

			const newOrder = newState.cardOrder.slice()
			newOrder.splice(position, 1)
			newState.cardOrder = newOrder
			return newState
		}
		case 'REPOSITION_CARD': {
			const { id, newPosition } = action

			let oldPosition
			newState.cardOrder.forEach((cardKey, index) => {
				if (cardKey === id) oldPosition = index
			})

			const newOrder = newState.cardOrder.slice()
			// Remove card from old spot
			newOrder.splice(oldPosition, 1)

			// Replace card into new spot
			newOrder.splice(newPosition, 0, id)
			newState.cardOrder = newOrder
			return newState
		}
	}

	return state
}

module.exports = cards
