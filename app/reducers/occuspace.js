const initialState = {
	data: [],
	selectedLocations: ['Geisel Library'],
	lastUpdated: null
}
// selectedLocations is an array that holds all the occuspace locations that are currently selected
// data is a map of strings to objects where each string is the locationName associated with occuspace object
// lastUpdated is the last time we fetched data from the occuspace api
function occuspace(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_OCCUSPACE_DATA': {
			newState.data = [...action.data]
			newState.lastUpdated = new Date().getTime()
			return newState
		}
		case 'SET_SELECTED_OCCUSPACE_LOCATIONS': {
			let temp = [...state.selectedLocations]
			if (action.add) {
				temp.push(action.name)
			} else {
				temp = temp.filter(e => e !== action.name)
			}
			newState.selectedLocations = [...temp]
			return newState
		}
		case 'SYNC_OCCUSPACE_LOCATION_DATA': {
			newState.selectedLocations = [...action.prevSlectedOccuspaceLocations]
			return newState
		}

		default:
			return state
	}
}

module.exports = occuspace
