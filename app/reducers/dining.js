const initialState = {
	data: null,
	lastUpdated: new Date().getTime(),
};

function dining(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_DINING': {
		newState.data = action.sortedData;

		return newState;
	}
	case 'SET_DINING_UPDATE': {
		newState.lastUpdated = action.nowTime;

		return newState;
	}
	default:
		return state;
	}
}

module.exports = dining;
