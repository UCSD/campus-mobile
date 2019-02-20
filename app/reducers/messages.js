const initialState = {
	messages: [],
	nextTimestamp: null,
	unreadMessages: 1,
	topics: [],
	lastMessageSeenTimeStamp: null
}

function messages(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'CLEAR_MESSAGE_DATA': {
			newState.messages = []
			return newState
		}
		case 'SET_TOPICS': {
			newState.topics = [...action.topics]
			return newState
		}
		case 'SET_MESSAGES': {
			const { messages: newMessages, nextTimestamp } = action
			newState.messages = [...newMessages]
			newState.nextTimestamp = nextTimestamp
			return newState
		}
		case 'SET_UNREAD_MESSAGES': {
			const { count } = action
			newState.unreadMessages = count
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
		case 'SET_LAST_MESSAGE_SEEN_TIME_STAMP': {
			newState.lastMessageSeenTimeStamp = action.timestamp
			return newState
		}
		default:
			return state
	}
}

module.exports = messages
