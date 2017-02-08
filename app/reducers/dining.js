const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function dining(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_DINING': {
		newState.data = action.dining;
		newState.lastUpdated = new Date().getTime();

		return newState;
	}
	default:
		return state;
	}
}

module.exports = dining;
