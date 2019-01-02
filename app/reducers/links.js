const initialState = {
	data: null,
	lastUpdated: 0,
}

function links(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_LINKS': {
			newState.data = action.links
			newState.lastUpdated = new Date().getTime()

			return newState
		}
		default:
			return state
	}
}

module.exports = links
