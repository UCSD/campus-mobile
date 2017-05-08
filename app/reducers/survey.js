const initialState = {
	byId: {},
	allIds: [],
	doneIds: [],
};

function survey(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SURVEY_DONE': {
		const arr = newState.doneIds.slice();
		arr.push(action.id);
		newState.doneIds = arr;

		return newState;
	}
	case 'SET_SURVEYS': {
		newState.byId = action.surveys.byId;
		newState.allIds = action.surveys.allIds;
		return newState;
	}
	default:
		return state;
	}
}

module.exports = survey;
