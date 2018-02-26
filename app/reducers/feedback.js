const initialState = {
	comment: '',
	name: '',
	email: '',
	commentHeight: 0,
	status: {
		requesting: false
	}
};

function feedback(state = initialState, action) {
	const newState = { ...state };

	switch (action.type) {
	case 'SET_FEEDBACK_STATE': {
		return Object.assign({}, action.newFeedback);
	}
	case 'FEEDBACK_POST_SUCCEEDED': {
		const resetFeedback = Object.assign({}, initialState);
		resetFeedback.status = {
			response: action.response,
			requesting: false
		};
		delete newState.status.timeRequested;
		resetFeedback.commentHeight = 0;
		return resetFeedback;
	}
	case 'FEEDBACK_POST_FAILED': {
		newState.status = {
			error: action.error,
			requesting: false
		};
		delete newState.status.timeRequested;
		return newState;
	}
	case 'FEEDBACK_POST_TIMEOUT': {
		newState.status = {
			error: new Error('Request timed out.'),
			requesting: false
		};
		delete newState.status.timeRequested;
		return newState;
	}
	default:
		return state;
	}
}

module.exports = feedback;
