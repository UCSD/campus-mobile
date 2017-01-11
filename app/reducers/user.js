import { LOGGED_IN, LOGGING_IN, LOGGED_OUT } from '../actions/user';

export type State = {
	isLoggedIn: boolean;
	isLoggingIn: boolean;
	auth: ?Object;
	profile: ?Object;
};

const initialState = {
	isLoggedIn: false,
	isLoggingIn: false,
	auth: null,
	profile: null,
};

function user(state: State = initialState, action): State {
	if (action.type === LOGGED_IN) {
		const { auth, profile } = action.data;
		return {
			...state,
			isLoggedIn: true,
			isLoggingIn: false,
			auth,
			profile,
		};
	}
	if (action.type === LOGGING_IN) {
		return {
			...state,
			isLoggingIn: true,
		};
	}
	if (action.type === LOGGED_OUT) {
		return {
			...state,
			...initialState,
		};
	}
	return state;
}

module.exports = user;
