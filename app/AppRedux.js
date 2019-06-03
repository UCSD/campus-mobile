import { AsyncStorage } from 'react-native'
import { createStore, applyMiddleware, compose } from 'redux'
import { persistStore, autoRehydrate } from 'redux-persist'
import thunkMiddleware from 'redux-thunk'
import createFilter from 'redux-persist-transform-filter'
import createSagaMiddleware from 'redux-saga'
import createMigration from 'redux-persist-migrate'

import rootSaga from './sagas/rootSaga'
import rootReducer from './reducers'

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
	7: state => ({ ...state, surf: undefined }), // 5.5 migration
	8: state => ({ ...state, dining: undefined, specialEvents: undefined }), // 5.6 migration
	9: state => ({ ...state, cards: undefined }), // 6.0 migration
	10: (state) => {
		const newState = { ...state }
		if (state.cards && state.cards.cardOrder) {
			// Add parking card if it doesn't exist
			if (state.cards.cards) {
				if (!state.cards.cards.parking) {
					state.cards.cards = {
						...state.cards.cards,
						parking: {
							id: 'parking',
							active: true,
							name: 'Parking',
							component: 'ParkingCard'
						}
					}
				}
			}

			if (Array.isArray(state.cards.cardOrder)
				&& state.cards.cardOrder.indexOf('parking') < 0) {
				newState.cards.cardOrder.splice(1, 0, 'parking')
			}
		}

		// Create default preferences for notifications
		if (state.user && state.user.profile) {
			newState.user.profile.subscribedTopics = [
				'emergency',
				'all'
			]
		}
		return newState
	}, // 6.1 messages migration
	11: (state) => {
		const newState = { ...state }
		if (state.cards && state.cards.cardOrder) {
			// Add parking card if it doesn't exist
			if (state.cards.cards) {
				if (!state.cards.cards.studentId) {
					state.cards.cards = {
						...state.cards.cards,
						studentId: {
							id: 'studentId',
							active: true,
							name: 'Student ID',
							component: 'StudentIDCard',
							authenticated: true,
							classifications: { student: true }
						}
					}
				}
			}
		}
		return newState // 6.7 studentId migration
	}
}

// reducerKey is the key of the reducer you want to store the state version in
const reducerKey = 'home'
const migration = createMigration(manifest, reducerKey)

export default function AppRedux(initialState, onComplete = () => null) {
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
