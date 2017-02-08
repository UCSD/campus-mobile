import { AsyncStorage } from 'react-native';
import { createStore, applyMiddleware } from 'redux';
import { persistStore, autoRehydrate } from 'redux-persist';
import thunkMiddleware from 'redux-thunk';
import createLogger from 'redux-logger';

import rootReducer from '../reducers';

const loggerMiddleware = createLogger();

export default function configureStore(initialState, onComplete: ?() => void) {
	const store = createStore(
		rootReducer,
		applyMiddleware(
			thunkMiddleware, // lets us dispatch() functions
			loggerMiddleware // neat middleware that logs actions
		),
		autoRehydrate()
	);

	if (module.hot) {
		// Enable Webpack hot module replacement for reducers
		module.hot.accept('../reducers', () => {
			const nextRootReducer = require('../reducers');

			store.replaceReducer(nextRootReducer);
		});
	}

	persistStore(store, { storage: AsyncStorage, whitelist: ['cards', 'shuttle', 'map', 'user', 'weather', 'surf', 'dining'] }, onComplete);
	return store;
}
