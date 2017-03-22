import { AsyncStorage } from 'react-native';
import { createStore, applyMiddleware } from 'redux';
import { persistStore, autoRehydrate } from 'redux-persist';
import thunkMiddleware from 'redux-thunk';
import createLogger from 'redux-logger';
import createFilter from 'redux-persist-transform-filter';
import createSagaMiddleware from 'redux-saga';

import rootSaga from '../sagas/rootSaga';
import rootReducer from '../reducers';
import { DEBUG_ENABLED } from '../AppSettings';

const sagaMiddleware = createSagaMiddleware();

const saveMapFilter = createFilter(
	'map',
	['history']
);
// empty vehicles
const saveShuttleFilter = createFilter(
	'shuttle',
	[
		'toggles',
		'routes',
		'stops',
		'closestStop',
		'lastUpdated'
	]
);


export default function configureStore(initialState, onComplete: ?() => void) {
	const middlewares = [sagaMiddleware, thunkMiddleware]; // lets us dispatch() functions

	if ( DEBUG_ENABLED ) {
		// neat middleware that logs actions
		const loggerMiddleware = createLogger();
		middlewares.push(loggerMiddleware);
	}

	const store = createStore(
		rootReducer,
		applyMiddleware(...middlewares),
		autoRehydrate()
	);

	sagaMiddleware.run(rootSaga);

	if (module.hot) {
		// Enable Webpack hot module replacement for reducers
		module.hot.accept('../reducers', () => {
			const nextRootReducer = require('../reducers');

			store.replaceReducer(nextRootReducer);
		});
	}

	persistStore(store,
		{
			storage: AsyncStorage,
			transforms: [saveMapFilter, saveShuttleFilter],
		},
		onComplete
	);
	return store;
}
