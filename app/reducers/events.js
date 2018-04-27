const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function events(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_EVENTS': {
		newState.data = action.events;
		newState.lastUpdated = new Date().getTime();

		return newState;
	}
	default:
		return state;
	}
}

module.exports = events;
