const initialState = {
	data: null,
	lastUpdated: null,
};

function conference(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_CONFERENCE_SCHEDULE': {
		newState.data = action.schedule;
		newState.lastUpdated = new Date().getTime();
		console.log(JSON.stringify(newState.data));
		return newState;
	}
	default:
		return state;
	}
}

module.exports = conference;
