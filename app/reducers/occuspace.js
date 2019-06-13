const initialState = {
	data: null,
	selectedLocations: [],
	selectedLocationObjs: [],
	lastUpdated: null
}
// selectedLocations is a an array of strings that holds all the currently selected occuspace locations
// data is a map of strings to objects where each string is the locationName associated with occuspace object
// locationObjs is an array of occuspace objects that are currently selected
// lastUpdated is the last time we fetched data from the occuspace api
function occuspace(state = initialState, action) {
	const newState = { ...state }
	switch (action.type) {
		case 'SET_OCCUSPACE_DATA': {
			newState.data = action.occuspaceData
			newState.lastUpdated = new Date().getTime()
			return newState
		}
		case 'SET_SELECTED_OCCUSPACE_LOCATIONS': {
			newState.selectedLocations = [...action.selectedLocations]
			return newState
		}
		case 'SET_OCCUSPACE_LOCATION_OBJS': {
			newState.selectedLocationObjs = [...action.selectedLocationObjs]
			return newState
		}
		default:
			return state
	}
}

module.exports = occuspace
