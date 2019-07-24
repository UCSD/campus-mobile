import React, { Component } from 'react'
import { Provider } from 'react-redux'
import { PersistGate } from 'redux-persist/integration/react'

import storeAndPersistor from '../redux-persist/configureStore'
import CounterAction from './Actions/CounterAction'

export default class react_redux_test extends Component {
	constructor(props){
		super(props)
	}

	render() {
		return (
			<Provider store={storeAndPersistor.store}>
				<PersistGate loading={null} persistor={storeAndPersistor.persistor}>
					<CounterAction />
				</PersistGate>
			</Provider>
		)
	}
}