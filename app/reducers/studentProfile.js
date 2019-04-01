const initialState = {
	data: null
}

function studentProfileReducer(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_STUDENT_PROFILE':
			newState.data = action.studentProfile
			console.log(action)
			return newState
		case 'CLEAR_STUDENT_PROFILE_DATA':
			return initialState
		default:
			return state
	}
}

module.exports = studentProfileReducer
