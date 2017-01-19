const cardsActions = require('./cards');
const shuttleActions = require('./shuttle');

module.exports = {
	...cardsActions,
	...shuttleActions
};
