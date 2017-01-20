import cardsActions from './cards';
import * as userActions from './user'; // ES6 way

module.exports = {
	...cardsActions,
	...userActions,
};
