const initialState = {
	comment: '',
	name: '',
	email: '',
}

function feedback(state = initialState, action) {
	switch (action.type) {
		case 'SET_FEEDBACK_STATE': {
			return Object.assign({}, action.feedback)
		}
		case 'SET_FEEDBACK_RESPONSE': {
			const feedbackWithResponse = Object.assign({}, initialState)
			feedbackWithResponse.response = action.response
			return feedbackWithResponse
		}
		default: {
			return state
		}
	}
}

module.exports = feedback
