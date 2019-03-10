const initialState = {
	sessions: []
}

function supplementalInstructionReducer(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_SI_SESSIONS': {
			const { parsedSessions: sessions } = action
			newState.sessions = sessions
			return newState
		}
		default:
			return state
	}
}

module.exports = supplementalInstructionReducer
