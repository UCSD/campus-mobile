import { createStore, applyMiddleware } from 'redux'
import { persistStore, persistCombineReducers } from 'redux-persist'
import storage from 'redux-persist/lib/storage' // defaults to localStorage for web
import logger from 'redux-logger'
import { createBlacklistFilter } from 'redux-persist-transform-filter'
import createSagaMiddleware from 'redux-saga'

import rootReducer from '../react-redux/Reducers/index'
import mySaga from '../redux-saga/saga'


// you want to remove some keys before you save
const saveSubsetBlacklistFilter = createBlacklistFilter(
	'CounterReducer',
	['count']
)

const persistConfig = {
	key: 'root',
	storage,
	transforms: [saveSubsetBlacklistFilter]
}
const sagaMiddleware = createSagaMiddleware()

const persistedReducer = persistCombineReducers(persistConfig, rootReducer)

const store = createStore(persistedReducer, applyMiddleware(sagaMiddleware, logger))

const persistor = persistStore(store, null,(err, restoredState) => { store.getState() })

const storeAndPersistor = { store, persistor }

sagaMiddleware.run(mySaga)

export default storeAndPersistor
