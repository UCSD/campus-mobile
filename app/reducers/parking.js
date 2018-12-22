const initialState = {
	isChecked: [true, true, true, false, false],
	selectedSpots: ['S', 'B', 'A'],
	parkingData: [],
	selectedLots: ['Osler'],
	showWarning: false,
	lastUpdated: null,
}

function parking(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_PARKING_TYPE_SELECTION': {
			newState.isChecked = action.isChecked
			const tempArray = []
			for (let i = 0; i < 5; i++) {
				switch (i) {
					case 0:
						if (newState.isChecked[i]) tempArray.push('S')
						break
					case 1:
						if (newState.isChecked[i]) tempArray.push('B')
						break
					case 2:
						if (newState.isChecked[i]) tempArray.push('A')
						break
					case 3:
						if (newState.isChecked[i]) tempArray.push('Accessible')
						break
					case 4:
						if (newState.isChecked[i]) tempArray.push('V')
						break
				}
			}
			newState.selectedSpots = [...tempArray]
			return newState
		}
		case 'SET_PARKING_DATA': {
			newState.parkingData = [...action.parkingData]
			newState.lastUpdated = new Date().getTime()
			return newState
		}
		case 'SET_WARNING_SIGN': {
			newState.showWarning = action.showWarning
			return newState
		}
		case 'SET_PARKING_LOT_SELECTION': {
			let temp = [...state.selectedLots]
			if (action.add) {
				temp.push(action.name)
			} else {
				temp = temp.filter(e => e !== action.name)
			}
			newState.selectedLots = [...temp]
			return newState
		}
		case 'SYNC_PARKING_LOTS_DATA': {
			newState.selectedLots = [...action.prevSelectedParkingLots]
			return newState
		}
		default:
			return state
	}
}

module.exports = parking
