const initialState = {
	data: null,
	lastUpdated: 0,
}

function promotions(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_PROMOTION': {
			newState.data = action.promotions
			newState.lastUpdated = new Date().getTime()
			return newState
		}
		default:
			return state
	}
}

module.exports = promotions
