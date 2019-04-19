const initialState = {
	data: null
}

function occuspace(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_OCCUSPACE_DATA': {
			newState.data = action.occuspaceData
			return newState
		}
		default:
			return state
	}
}

module.exports = occuspace
