const initialState = {
	tutorSession: null
}

function tutorSessionReducer(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_TUTOR_SESSIONS': {
			newState.tutorSession = action
			return newState
		}
		default:
			return state
	}
}

module.exports = tutorSessionReducer
