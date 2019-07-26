import { createStore, applyMiddleware } from 'redux'
import { persistStore, persistCombineReducers } from 'redux-persist'
import storage from 'redux-persist/lib/storage' // defaults to localStorage for web
import logger from 'redux-logger'
import { createBlacklistFilter } from 'redux-persist-transform-filter'
import CounterReducer from '../react-redux/Reducers/CounterReducer'

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

const persistedReducer = persistCombineReducers(persistConfig, { CounterReducer })

const store = createStore(persistedReducer, applyMiddleware(logger))

const persistor = persistStore(store, null,(err, restoredState) => { store.getState() })

const storeAndPersistor = { store, persistor }

export default storeAndPersistor
