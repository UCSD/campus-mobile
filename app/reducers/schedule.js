const initialState = {
	data: null,
	lastUpdated: 0,
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
		case 'CLEAR_SCHEDULE_DATA':
			return initialState
		default:
			return state
	}
}

module.exports = schedule
