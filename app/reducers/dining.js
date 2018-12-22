const initialState = {
	data: null,
	menus: [],
	lastUpdated: 0,
	lookup: null
}

function dining(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_DINING': {
			// create a lookup object for restaurant IDs
			const newLookup = {}

			for (let i = 0; i < action.data.length; i++) {
				newLookup[action.data[i].id] = i
			}

			return Object.assign({}, newState, {
				data: action.data,
				lastUpdated: Date().now(),
				lookup: newLookup
			})
		}
		case 'SET_DINING_MENU': {
			const newMenusArray = {
				...newState.menus,
				[action.id]: {
					...action.data,
					lastUpdated: Date().now(),
				}
			}

			newState.menus = newMenusArray
			return newState
		}
		default:
			return state
	}
}

module.exports = dining
