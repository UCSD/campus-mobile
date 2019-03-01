const initialState = {
	tutorSessions: null
}

function tutorSessions(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_TUTOR_SESSIONS': {
			newState.tutorSessions = action
			break
		}
		default:
			return state
	}
}

module.exports = tutorSessions
