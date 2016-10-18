import { createStore, applyMiddleware } from 'redux'
import { browserHistory } from 'react-router'

import rootReducer from '../reducers'
import thunkMiddleware from 'redux-thunk'
import createLogger from 'redux-logger'
import { syncHistory, routeReducer } from 'react-router-redux'

const loggerMiddleware = createLogger()
const reduxRouterMiddleware = syncHistory(browserHistory)

export default function configureStore(initialState) {
  return createStore(
    rootReducer,
    applyMiddleware(
      reduxRouterMiddleware,
      thunkMiddleware, // lets us dispatch() functions
      loggerMiddleware // neat middleware that logs actions
    ),
    initialState
  )
}
