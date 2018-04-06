import React from 'react'
import { StatusBar, Alert, AsyncStorage } from 'react-native'
import { setJSExceptionHandler } from 'react-native-exception-handler'
import RNExitApp from 'react-native-exit-app'

// REDUX
import { Provider } from 'react-redux'
import configureStore from './store/configureStore'

import Main from './main'
import { platformAndroid } from './util/general'
import logger from './util/logger'
import { COLOR } from './styles/ColorConstants'

class CampusMobileSetup extends React.Component {
	constructor(props) {
		super(props)

		this.state = {
			store: configureStore({}, this.finishLoading),
			isLoading: true,
		}
	}

	finishLoading = () => {
		this.setState({ isLoading: false })

		const errorHandler = (e, isFatal) => {
			if (isFatal) {
				AsyncStorage.clear()

				let errorStr = 'Crash: ' + e.name + ': ' + e.message
				let errorStack

				try {
					errorStack = e.stack.replace(/.*\n/,'').replace(/\n.*/g, '').trim()
					errorStr += ' ' + errorStack
				} catch (stackErr) {
					logger.log('Error: ' + stackErr)
				}

				logger.trackException(errorStr, isFatal)

				Alert.alert(
					'Unexpected error occurred',
					'Please try restarting the app. If the app is still crashing, please keep an eye out for an update or try again later.',
					[{
						text: 'Okay',
						onPress: () => {
							RNExitApp.exitApp()
						}
					}]
				)
			} else {
				console.log(e) // So that we can see it in the ADB logs in case of Android if needed
			}
		}

		setJSExceptionHandler(errorHandler, true)
	}

	render() {
		if (platformAndroid()) {
			StatusBar.setBackgroundColor(COLOR.PRIMARY, false)
		}

		if (!this.state.isLoading) {
			return (
				<Provider store={this.state.store}>
					<Main />
				</Provider>
			)
		} else {
			return null
		}
	}
}

module.exports = CampusMobileSetup
