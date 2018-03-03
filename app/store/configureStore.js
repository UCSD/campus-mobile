import { AsyncStorage } from 'react-native';
import { createStore, applyMiddleware } from 'redux';
import { persistStore, persistReducer, createMigrate } from 'redux-persist';
import thunkMiddleware from 'redux-thunk';
import createFilter from 'redux-persist-transform-filter';
import createSagaMiddleware from 'redux-saga';
import logger from 'redux-logger'

import rootSaga from '../sagas/rootSaga';
import rootReducer from '../reducers';

const reducers = require('../reducers');

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
		'lastUpdated',
		'savedStops',
	]
);

// Migration
const migrations = {
	1: (state) => ({ ...state }),
	2: (state) => ({ ...state, shuttle: Object.assign({}, state.shuttle, { savedStops: [], stops: {}, lastUpdated: 0 }) }),
	3: (state) => ({ ...state, shuttle: Object.assign({}, state.shuttle, { savedStops: [], stops: {}, lastUpdated: 0, closestStop: null }) }),
	4: (state) => ({ ...state, cards: undefined }), // clear cards for specialEvents
	5: (state) => ({ ...state, events: undefined }), // clear events data
	6: (state) => ({ ...state, cards: undefined, conference: undefined }), // clear cards/conference for specialEvents
	7: (state) => ({ ...state, surf: undefined }),
};

// reducerKey is the key of the reducer you want to store the state version in
const persistConfig = {
	key: 'home',
	version: 2,
	storage: AsyncStorage,
	migrate: createMigrate(migrations),
	transforms: [saveMapFilter, saveShuttleFilter]
};

export default function configureStore(initialState, onComplete: ?() => void) {
	const middlewares = [sagaMiddleware, thunkMiddleware]; // lets us dispatch() functions

	const logging = false;
	if (logging) {
		middlewares.push(logger);
	}

	const finalReducer = persistReducer(persistConfig, rootReducer);

	const store = createStore(
		finalReducer,
		applyMiddleware(...middlewares)
	);

	if (module.hot) {
		// Enable Webpack hot module replacement for reducers
		module.hot.accept('../reducers', () => {
			const nextRootReducer = reducers;

			store.replaceReducer(persistConfig, nextRootReducer);
		});
	}

	persistStore(
		store,
		null,
		() => {
			onComplete();
			sagaMiddleware.run(rootSaga);
		}
	);
	return store;
}
