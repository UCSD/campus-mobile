const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function schedule(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_SCHEDULE':
		newState.data = action.schedule;
		newState.lastUpdated = new Date().getTime();

		return newState;
	default:
		return state;
	}
}

module.exports = schedule;
