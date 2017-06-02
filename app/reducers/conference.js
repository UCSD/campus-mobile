const initialState = {
	data: null,
	lastUpdated: 0,
	saved: [],
};

function conference(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_CONFERENCE': {
		newState.data = action.conference;
		newState.lastUpdated = new Date().getTime();

		return newState;
	}
	case 'CHANGED_CONFERENCE_SAVED': {
		newState.saved = action.saved;
		return newState;
	}
	default:
		return state;
	}
}

module.exports = conference;
