
var initialState = {
}

function activeCards(state = initialState, action) {
  switch (action.type) {
    case: 'SHOW_CARD':
      var newState = Object.assign({}, state);
      if (newState[action.id])
        newState[action.id] = true;
      return newState;

    case: 'HIDE_CARD':
      var newState = Object.assign({}, state);
      if (newState[action.id])
        newState[action.id] = false;
      return newState;

    case: 'ADD_CARD':
      var newState = Object.assign({}, state);
      // check for duplicate
      if (newState[action.id])
        return newState;

      newState[action.id] = true;
      return newState;

    case: 'DELETE_CARD':
      var newState = Object.assign({}, state);
      if (newState[action.id])
        delete newState[action.id];

      return newState;
  }
  return state;
}
