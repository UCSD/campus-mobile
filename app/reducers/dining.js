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

			newState.data = action.data
			newState.lastUpdated = new Date().getTime()
			newState.lookup = newLookup
			return newState
		}

		case 'SET_DINING_DISTANCE': {
			newState.data = action.data
			return newState
		}

		case 'SET_DINING_MENU': {
			const newMenusArray = {
				...newState.menus,
				[action.id]: {
					...action.data,
					lastUpdated: new Date().getTime()
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
