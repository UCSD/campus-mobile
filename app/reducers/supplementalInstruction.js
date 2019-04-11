const initialState = {
	data: null
}

function supplementalInstructionReducer(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_SI_SESSIONS': {
			newState.data = action.sessions.data
			return newState
		}
		default:
			return state
	}
}

module.exports = supplementalInstructionReducer
