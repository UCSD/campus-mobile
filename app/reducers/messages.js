const initialState = {
	messages: null,
	nextTimestamp: null,
	loadingMoreData: false,
	topics: [
		{
			'audienceId': 'all',
			'topics': [
				{
					'topicId': 'all',
					'topicMetadata': {
						'name': 'General',
						'description': 'General messages for the whole UCSD community.'
					}
				}
			]
		}
	]
}

function messages(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_TOPICS': {
			newState.topics = [...action.topics]
			return newState
		}
		case 'SET_MESSAGES': {
			const { messages: newMessages, nextTimestamp } = action
			newState.messages = [...newMessages]
			newState.nextTimestamp = nextTimestamp
			newState.loadingMoreData = false
			return newState
		}
		case 'ADD_MESSAGES': {
			const { messages: newMessages, nextTimestamp } = action
			newState.messages = [...state.messages]
			// remove one duplicate message
			newMessages.shift()
			newState.messages = newState.messages.concat(newMessages)
			newState.nextTimestamp = nextTimestamp
			newState.loadingMoreData = false
			return newState
		}
		case 'GET_MESSAGES_REQUEST': {
			newState.loadingMoreData = true
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
