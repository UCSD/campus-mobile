const initialState = {
	data: null,
	lastUpdated: 0,
	saved: [],
};

function specialEvents(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_SPECIAL_EVENTS': {
		newState.data = action.specialEvents;
		newState.lastUpdated = new Date().getTime();

		return newState;
	}
	case 'CHANGED_SPECIAL_EVENTS_SAVED': {
		newState.saved = action.saved;
		return newState;
	}
	default:
		return state;
	}
}

module.exports = specialEvents;
