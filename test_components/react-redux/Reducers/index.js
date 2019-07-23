import { combineReducers, createStore, applyMiddleware } from 'redux'
import logger from 'redux-logger'


import counterReducer from './CounterReducer'

const AppReducers = combineReducers({
	counterReducer,
})

const rootReducer = (state, action) => AppReducers(state,action)

// Logger with default options
const store = createStore(
	rootReducer,
	applyMiddleware(logger)
)

export default store
