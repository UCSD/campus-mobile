const initialState = {
	isLoggedIn: false,
	isLoggingIn: false,
	profile: {
		username: null
	},
	expiration: null,
	error: null
};

function user(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'IS_LOGGING_IN': {
		newState.isLoggingIn = true;
		return newState;
	}
	case 'LOGGED_IN': {
		newState.isLoggingIn = false;
		newState.error = null;
		newState.profile.username = action.user;
		newState.expiration = action.expiration;
		newState.isLoggedIn = true;
		return newState;
	}
	case 'LOGGED_OUT': {
		return initialState;
	}
	case 'USER_LOGIN_FAILED': {
		newState.isLoggedIn = false;
		newState.isLoggingIn = false;
		newState.error = action.error;
		return newState;
	}
	default:
		return state;
	}
}

module.exports = user;
