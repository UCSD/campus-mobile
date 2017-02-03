const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function weather(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_WEATHER':
		newState.data = action.weather;
		newState.lastUpdated = new Date().getTime();

		return newState;
	default:
		return state;
	}
}

module.exports = weather;
