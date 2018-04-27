
const initialState = {
	history: [],
	results: null
};

function map(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'UPDATE_HISTORY': {
		newState.history = action.history;
		return newState;
	}
	case 'SET_SEARCH_RESULTS': {
		newState.results = action.results;

		return newState;
	}
	default:
		return state;
	}
}

module.exports = map;
