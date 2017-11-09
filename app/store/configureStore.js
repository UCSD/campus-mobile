import { AsyncStorage } from 'react-native';
import { createStore, applyMiddleware, compose } from 'redux';
import { persistStore, autoRehydrate } from 'redux-persist';
import thunkMiddleware from 'redux-thunk';
import createLogger from 'redux-logger';
import createFilter from 'redux-persist-transform-filter';
import createSagaMiddleware from 'redux-saga';
import createMigration from 'redux-persist-migrate';

import rootSaga from '../sagas/rootSaga';
import rootReducer from '../reducers';

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
const manifest = {
	1: (state) => ({ ...state }),
	2: (state) => ({ ...state, shuttle: Object.assign({}, state.shuttle, { savedStops: [], stops: {}, lastUpdated: 0 }) }),
	3: (state) => ({ ...state, shuttle: Object.assign({}, state.shuttle, { savedStops: [], stops: {}, lastUpdated: 0, closestStop: null }) }),
	4: (state) => ({ ...state, cards: undefined }), // clear cards for specialEvents
	5: (state) => ({ ...state, events: undefined }), // clear events data
	6: (state) => ({ ...state, cards: undefined, conference: undefined }), // clear cards/conference for specialEvents
	7: (state) => ({ ...state, cards: undefined }), // clear cards for class schedule
};

// reducerKey is the key of the reducer you want to store the state version in
// in this example after migrations run `state.app.version` will equal `2`
const reducerKey = 'home';
const migration = createMigration(manifest, reducerKey);

export default function configureStore(initialState, onComplete: ?() => void) {
	const middlewares = [sagaMiddleware, thunkMiddleware]; // lets us dispatch() functions

	/*
	// neat middleware that logs actions
	const loggerMiddleware = createLogger();
	middlewares.push(loggerMiddleware);
	*/

	const enhancer =  compose(migration, autoRehydrate());

	const store = createStore(
		rootReducer,
		applyMiddleware(...middlewares),
		enhancer
	);

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
		() => {
			onComplete();
			sagaMiddleware.run(rootSaga);
		}
	);
	return store;
}
