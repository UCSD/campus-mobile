const initialState = {
	isLoggedIn: false,
	profile: {
		username: null,
		classifications: null,
		pid: null
	},
	expiration: null
}

function user(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
	case 'LOGGED_IN': {
		newState.isLoggedIn = true
		newState.profile = action.profile
		newState.expiration = action.expiration
		return newState
	}
	case 'LOGGED_OUT': {
		return initialState
	}
	default:
		return state
	}
}

module.exports = user
