
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
  }
  return state;
}
