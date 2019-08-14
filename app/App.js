/**
 * Campus Mobile Dependency Upgrade Testbed
 */
/* eslint react/jsx-pascal-case: 0 */
import React from 'react'
import { Provider } from 'react-redux'
import { PersistGate } from 'redux-persist/integration/react'

import storeAndPersistor from './configureStore'
import Router from './navigation/Router'


const App = () => (
	<Provider store={storeAndPersistor.store}>
		<PersistGate loading={null} persistor={storeAndPersistor.persistor}>
			<Router />
		</PersistGate>
	</Provider>
)

export default App
