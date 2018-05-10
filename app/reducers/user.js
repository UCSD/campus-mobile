const initialState = {
	isLoggedIn: false,
	profile: {
		username: null,
		classifications: null,
		pid: null
	},
	invalidSavedCredentials: false
}

function user(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'LOGGED_IN': {
			newState.isLoggedIn = true
			newState.profile = action.profile
			newState.invalidSavedCredentials = false
			return newState
		}
		case 'LOGGED_OUT': {
			return initialState
		}
		case 'PANIC_LOG_OUT': {
			const loggedOutState = initialState
			loggedOutState.invalidSavedCredentials = true
			return loggedOutState
		}
		case 'CLEAR_INVALID_CREDS_ERROR': {
			newState.invalidSavedCredentials = false
			return newState
		}
		default:
			return state
	}
}

module.exports = user
