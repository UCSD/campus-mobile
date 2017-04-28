const initialState = {
	lastScroll: 0
};

function home(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_HOME_SCROLL': {
		newState.lastScroll = action.lastScroll;
		return newState;
	}
	default:
		return state;
	}
}

module.exports = home;
