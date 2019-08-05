import { createStore, applyMiddleware } from 'redux'
import { persistStore, persistCombineReducers } from 'redux-persist'
import AsyncStorage from '@react-native-community/async-storage'
import logger from 'redux-logger'
import { createFilter } from 'redux-persist-transform-filter'
import createSagaMiddleware from 'redux-saga'

// import rootReducer from '../react-redux/Reducers/index'

import rootReducer from '../../app/reducers/index'
import mySaga from '../redux-saga/saga'


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

const persistConfig = {
	key: 'home',
	storage: AsyncStorage,
	transforms: [saveMapFilter, saveShuttleFilter]
}
const sagaMiddleware = createSagaMiddleware()

const persistedReducer = persistCombineReducers(persistConfig, rootReducer)

const store = createStore(persistedReducer, applyMiddleware(sagaMiddleware, logger))

const persistor = persistStore(store, null,(err, restoredState) => { store.getState() })

const storeAndPersistor = { store, persistor }

sagaMiddleware.run(mySaga)

export default storeAndPersistor
