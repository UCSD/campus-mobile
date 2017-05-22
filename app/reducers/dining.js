const initialState = {
	data: null,
	lastUpdated: 0,
};

function dining(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_DINING': {
		newState.data = action.data;
		newState.lastUpdated = new Date().getTime();

		return newState;
	}
	default:
		return state;
	}
}

module.exports = dining;
