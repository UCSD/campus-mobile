const initialState = {
	messages: null,
	nextTimestamp: null,
}

function messages(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_MESSAGES': {
			const { messages: newMessages, nextTimestamp } = action
			newState.messages = [...newMessages]
			newState.nextTimestamp = nextTimestamp
			return newState
		}
		case 'CONFIRM_REGISTRATION': {
			newState.registered = true
			return newState
		}
		case 'CONFIRM_DEREGISTRATION': {
			newState.registered = false
			return newState
		}
		default:
			return state
	}
}

module.exports = messages
