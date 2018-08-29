const initialState = {
	messages: null,
	nextTimestamp: null,
}

function messages(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_MESSAGES': {
			const { messages, nextTimestamp } = action
			newState.messages = [...messages]
			newState.nextTimestamp = nextTimestamp
			return newState
		}
		default:
			return state
	}
}

module.exports = messages
