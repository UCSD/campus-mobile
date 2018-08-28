const initialState = { isChecked: [false, false, false, false, false] }

function parking(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'UPDATE_PARKING_TYPE_SELECTION': {
			newState.isChecked = action.isChecked
			newState.count = action.count
			return newState
		}
		default:
			return state
	}
}

module.exports = parking