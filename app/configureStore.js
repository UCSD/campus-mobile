import { createStore, applyMiddleware, compose } from 'redux'
import { persistStore, persistCombineReducers, createMigrate } from 'redux-persist'
import AsyncStorage from '@react-native-community/async-storage'
import { createFilter } from 'redux-persist-transform-filter'
import createSagaMiddleware from 'redux-saga'
import { setJSExceptionHandler } from 'react-native-exception-handler'

import rootReducer from './reducers/index'
import rootSaga from './sagas/rootSaga'
import { gracefulFatalReset } from './util/general'

// you want to remove some keys before you save
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

const migrations = {
	0: state => ({
		...state,
		promotion: undefined
	}),
	1: state => ({
		...state,
		specialEvents: undefined
	}),
	2: (state) => {
		if (state.cards.cards) {
			if (!state.cards.cards.promotions) {
				state.cards.cards = {
					...state.cards.cards,
					promotions: {
						id: 'promotions',
						active: true,
						autoActivated: false,
						name: 'Notices',
						component: 'PromotionsCard'
					}
				}
			}
		}
		return state
	}
}

const persistConfig = {
	key: 'home',
	storage: AsyncStorage,
	transforms: [saveMapFilter, saveShuttleFilter],
	migrate: createMigrate(migrations, { debug: false })
}
// custom composer for redux devtools
const composeWithTools = 
	typeof window === 'object' && 
	window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ? 
		window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose


const sagaMiddleware = createSagaMiddleware()

const enhancer =  composeWithTools(applyMiddleware(sagaMiddleware))

const persistedReducer = persistCombineReducers(persistConfig, rootReducer)

const store = createStore(persistedReducer, undefined, enhancer)

const finishLoading = () => {
	const errorHandler = (e, isFatal) => {
		if (isFatal) {
			gracefulFatalReset(new Error('Crash: ' + e.name + ': ' + e.message + ': ' + e.stack))
		}
	}
	setJSExceptionHandler(errorHandler, true)
}

const persistor = persistStore(store, finishLoading)

const storeAndPersistor = { store, persistor }

sagaMiddleware.run(rootSaga)

export default storeAndPersistor
