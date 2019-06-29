const initialState = {
  searchInput: '',
  filterVisible: false,
}

function course( state = initialState, action ) {
  const newState = { ...state }

  switch (action.type) {
    case 'UPDATE_SEARCH_INPUT': {
      newState.searchInput = action.searchInput;
      return newState
    }
    case 'CHANGE_FILTER_STATUS': {
      newState.filterVisible = action.filterVisible;
      return newState
    }
    default:
      return state
  }
}

module.exports = course