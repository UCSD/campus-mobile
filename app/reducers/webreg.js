const initialState = {
	data: null,
	lastUpdated: 0,
	currentTerm: null,
	searchInput: '',
	filterVisible: false,
	termSwitcherVisible: false,
	termSelectorVisible: false,
	filterVal: [false, false, false]
}

function schedule(state = initialState, action) {
	const newState = { ...state }

	switch (action.type) {
		case 'SET_SCHEDULE':
			newState.data = action.schedule
			newState.lastUpdated = new Date().getTime()
			return newState
		case 'SET_SCHEDULE_TERM':
			newState.currentTerm = action.term
			return newState
		case 'CLEAR_SCHEDULE_DATA':
			return initialState
		case 'UPDATE_SEARCH_INPUT': {
			newState.searchInput = action.searchInput
			return newState
		}
		case 'CHANGE_FILTER_VISIBILITY': {
			newState.filterVisible = action.filterVisible
			return newState
		}
		case 'CHANGE_TERM_SWITCHER_VISIBILITY': {
			newState.termSwitcherVisible = action.termSwitcherVisible
			return newState
		}
		case 'CHANGE_TERM_SELECTOR_VISIBILITY': {
			newState.termSelectorVisible = action.termSelectorVisible
			return newState
		}
		case 'UPDATE_FILTER': {
			return { ...state, filterVal: action.filterVal }
		}
		default:
			return state
	}
}

module.exports = schedule
