const cardsActions = require('./cards');
const shuttleActions = require('./shuttle');
const mapActions = require('./map');

module.exports = {
	...cardsActions,
	...shuttleActions,
	...mapActions,
};
