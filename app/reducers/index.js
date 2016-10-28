var { combineReducers } = require('redux');

var cardsReducer = require('./cards');

module.exports = combineReducers({
  cards: cardsReducer
});
