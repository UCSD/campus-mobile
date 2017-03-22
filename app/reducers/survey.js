const initialState = {
	answered: [],
};

function survey(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SURVEY_RECEIVED': {
		const answers = newState.answered;
		answers.push = action.id;
		newState.answered = answers;

		return newState;
	}
	default:
		return state;
	}
}

module.exports = survey;
