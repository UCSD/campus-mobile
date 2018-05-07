const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
	currentTerm: null
}

function schedule(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_SCHEDULE':
			newState.data = action.schedule
			newState.lastUpdated = new Date().getTime()
			return newState
		case 'SET_SCHEDULE_TERM':
			newState.currentTerm = action.term
			return newState
		default:
			return state
	}
}

module.exports = schedule
