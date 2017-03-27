const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function events(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_EVENTS': {
		newState.data = action.events;

		return newState;
	}
	case 'SET_EVENTS_UPDATE': {
		newState.lastUpdated = action.nowTime;

		return newState;
	}
	default:
		return state;
	}
}

module.exports = events;
