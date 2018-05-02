import { AsyncStorage } from 'react-native'
import { createStore, applyMiddleware, compose } from 'redux'
import { persistStore, autoRehydrate } from 'redux-persist'
import thunkMiddleware from 'redux-thunk'
import createFilter from 'redux-persist-transform-filter'
import createSagaMiddleware from 'redux-saga'
import createMigration from 'redux-persist-migrate'

import rootSaga from '../sagas/rootSaga'
import rootReducer from '../reducers'

// immutable module import is ignored by eslint because it is
// only used when the app is running in dev mode
// eslint-disable-next-line import/no-extraneous-dependencies
const immutable = require('redux-immutable-state-invariant')

const sagaMiddleware = createSagaMiddleware()
const saveMapFilter = createFilter(
	'map',
	['history']
)
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
)

// Migration
const manifest = {
	1: state => ({ ...state }),
	2: state => ({ ...state, shuttle: Object.assign({}, state.shuttle, { savedStops: [], stops: {}, lastUpdated: 0 }) }),
	3: state => ({ ...state, shuttle: Object.assign({}, state.shuttle, { savedStops: [], stops: {}, lastUpdated: 0, closestStop: null }) }),
	4: state => ({ ...state, cards: undefined }),
	5: state => ({ ...state, events: undefined }),
	6: state => ({ ...state, cards: undefined, conference: undefined }),
	7: state => ({ ...state, surf: undefined }), // 5.5 migration
	8: state => ({ ...state, dining: undefined, specialEvents: undefined }), // 5.6 migration
}

// reducerKey is the key of the reducer you want to store the state version in
const reducerKey = 'home'
const migration = createMigration(manifest, reducerKey)

export default function configureStore(initialState, onComplete = () => null) {
	const middlewares = [sagaMiddleware, thunkMiddleware] // lets us dispatch() functions

	// If in development, add redux-immutable-state-invariant
	if (__DEV__) {
		middlewares.push(immutable.default())
	}

	// custom composer for redux devtools
	const composeWithTools =
		typeof window === 'object' &&
		window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
			window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) :
			compose

	const enhancer =  composeWithTools(migration, autoRehydrate())
	const store = createStore(
		rootReducer,
		enhancer,
		applyMiddleware(...middlewares),
	)

	persistStore(store, {
		storage: AsyncStorage,
		transforms: [saveMapFilter, saveShuttleFilter],
	}, () => {
		onComplete()
		sagaMiddleware.run(rootSaga)
	})

	return store
}
