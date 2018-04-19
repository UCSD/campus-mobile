const initialState = {
	onBoardingViewed: false
}

function routes(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
	case 'SET_ONBOARDING_VIEWED': {
		newState.onBoardingViewed = true
		return newState
	}
	default:
		return state
	}
}

module.exports = routes
