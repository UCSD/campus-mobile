import { combineReducers } from 'redux'


import counterReducer from './CounterReducer'

const AppReducers = combineReducers({
	counterReducer,
})

const rootReducer = (state, action) => AppReducers(state,action)

export default rootReducer
