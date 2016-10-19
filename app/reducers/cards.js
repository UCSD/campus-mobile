
var initialState = {
}

function cards(state = initialState, action) {
  switch (action.type) {
    case 'SHOW_CARD':
      var newState = {...state};
      if (newState[action.id])
        newState[action.id] = true;
      return newState;

    case 'HIDE_CARD':
      var newState = {...state};
      if (newState[action.id])
        newState[action.id] = false;
      return newState;

    case 'ADD_CARD':
      var newState = {...state};
      // check for duplicate, early exit
      if (newState[action.id])
        return newState;

      newState[action.id] = true;
      return newState;

    case 'DELETE_CARD':
      var newState = {...state};
      delete newState[action.id];
      return newState;
  }
  return state;
}

module.exports = cards
