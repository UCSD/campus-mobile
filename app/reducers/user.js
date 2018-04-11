const initialState = {
	isLoggedIn: false,
	auth: null,
	profile: null,
	username: null,
};

function user(state = initialState, action) {
	if (action.type === 'LOGGED_IN') {
		//const { auth, profile } = action.data;
		return {
			...state,
			isLoggedIn: true,
			username: action.user
			//auth,
			//profile,
		};
	}
	if (action.type === 'LOGGED_OUT') {
		return {
			...state,
			...initialState,
		};
	}
	return state;
}

module.exports = user;
