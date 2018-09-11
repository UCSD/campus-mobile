const initialState = { isActive: [false, false, false] }

function notifications(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_NOTIFICATION_STATE': {
			newState.isActive = action.isActive
			return newState
		}
		default:
			return state
	}
}

module.exports = notifications