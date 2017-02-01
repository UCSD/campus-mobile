<<<<<<< HEAD
import cardsActions from './cards';
import * as userActions from './user'; // ES6 way
import * as shuttleActions from './shuttle';
import * as mapActions from './map';

module.exports = {
	...cardsActions,
	...shuttleActions,
	...mapActions,
	...userActions,
};
