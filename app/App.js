import React from 'react'
import { Provider } from 'react-redux'
import { PersistGate } from 'redux-persist/integration/react'
import PushNotificationContainer from './containers/pushNotificationContainer'
import storeAndPersistor from './configureStore'
import Router from './navigation/Router'

const App = () => (
	<Provider store={storeAndPersistor.store}>
		<PersistGate loading={null} persistor={storeAndPersistor.persistor}>
			<PushNotificationContainer />
			<Router />
		</PersistGate>
	</Provider>
)

export default App
