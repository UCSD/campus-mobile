import React, { Component } from 'react'
import { View, StatusBar } from 'react-native'
import { setJSExceptionHandler } from 'react-native-exception-handler'
import { Provider } from 'react-redux'
import AppRedux from './AppRedux'
import PushNotificationContainer from './containers/pushNotificationContainer'
import AppStateContainer from './containers/appStateContainer'
import Router from './navigation/Router'
import { gracefulFatalReset, platformIOS } from './util/general'
import css from './styles/css'

export default class App extends Component {
	constructor(props) {
		super(props)
		this.state = {
			store: AppRedux({}, this.finishLoading),
			isLoading: true,
		}
	}

	finishLoading = () => {
		this.setState({ isLoading: false })
		const errorHandler = (e, isFatal) => {
			if (isFatal) {
				gracefulFatalReset(new Error('Crash: ' + e.name + ': ' + e.message + ': ' + e.stack))
			}
		}
		setJSExceptionHandler(errorHandler, true)
	}

	render() {
		if (platformIOS()) {
			StatusBar.setBarStyle('light-content')
		}

		if (!this.state.isLoading) {
			return (
				<Provider store={this.state.store}>
					<View style={css.main}>
						<PushNotificationContainer />
						<AppStateContainer />
						<Router />
					</View>
				</Provider>
			)
		} else {
			return null
		}
	}
}
