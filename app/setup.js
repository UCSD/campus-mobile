import React from 'react'
import { setJSExceptionHandler } from 'react-native-exception-handler'
import { Provider } from 'react-redux'

import configureStore from './store/configureStore'
import Main from './main'
import { gracefulFatalReset } from './util/general'

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
				gracefulFatalReset(new Error('Crash: ' + e.name + ': ' + e.message + ': ' + e.stack))
			}
		}
		setJSExceptionHandler(errorHandler, true)
	}

	render() {
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
