const initialState = {
	isChecked: [false, false, false, false, false],
	count: 0,
	parkingData: []
}

function parking(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_PARKING_TYPE_SELECTION': {
			newState.isChecked = action.isChecked
			newState.count = action.count
			return newState
		}
		case 'SET_PARKING_DATA': {
			newState.parkingData[0] = action.ParkingData
			return newState
		}
		default:
			return state
	}
}

module.exports = parking