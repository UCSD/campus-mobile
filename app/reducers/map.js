
const initialState = {
	history: [],
	results: null
};

function map(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SAVE_SEARCH': {
		// Check if in history already, if yes move up
		const termIndex = newState.history.indexOf(action.term);
		if ( termIndex !== -1) {
			newState.history = [...newState.history.splice(termIndex, 1), ...newState.history];
		} else {
			newState.history = [action.term, ...newState.history];
		}

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
