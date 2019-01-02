const initialState = {
	isActive: [false, false, false, false, false, false],
	selectedParking: null,
	parkingStartTimes: ['11am','11am','11am'],
	parkingStopTimes: ['11pm', '11pm', '11pm']
}

function notifications(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_NOTIFICATION_STATE': {
			newState.isActive = action.isActive
			return newState
		}
		case 'SET_PARKING_NOTIFICATION_STATE': {
			if (newState.selectedParking === action.selectedParking) {
				newState.selectedParking = null
				return newState
			}
			newState.selectedParking = action.selectedParking
			return newState
		}
		case 'SET_PARKING_START_TIME': {
			newState.parkingStartTimes = action.parkingStartTimes
			return newState
		}
		case 'SET_PARKING_STOP_TIME': {
			newState.parkingStopTimes = action.parkingStopTimes
			return newState
		}
		default:
			return state
	}
}

module.exports = notifications