const initialState = {
	isChecked: [true, true, true, false, false],
	selectedSpots: ['S', 'B', 'A'],
	count: 3,
	parkingData: [],
	parkingLotsData: [],
	selectedLots: [],
	showWarning: false
}

function parking(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_PARKING_TYPE_SELECTION': {
			newState.isChecked = action.isChecked
			newState.count = action.count
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
			newState.parkingData = [action.ParkingData]
			return newState
		}
		case 'SET_WARNING_SIGN': {
			newState.showWarning = action.showWarning
			return newState
		}
		case 'SET_PARKING_LOT_DATA': {
			newState.parkingLotsData = [...action.ParkingLotData]
			return newState
		}
		// for some reason this is saying that i modifed state
		case 'SET_PARKING_LOT_SELECTION': {
			const tempObj = {...state.parkingLotsData[action.index]}
			tempObj.active = action.value
			newState.parkingLotsData = [...state.parkingLotsData]
			newState.parkingLotsData[action.index] = tempObj
			return newState
		}
		case 'EDIT_LOCAL_LOT_SELECTION': {
			const tempArray = []
			state.parkingLotsData.forEach((lot) => {
				if (lot.active) {
					tempArray.push(lot.name)
				}
			})
			newState.selectedLots = [...tempArray]
			return newState
		}
		default:
			return state
	}
}

module.exports = parking
