import React from 'react';

// CODE PUSH
import codePush from 'react-native-code-push';

// REDUX
import { Provider } from 'react-redux';
import configureStore from './store/configureStore';

import nowucsandiego from './index';

const codePushOptions = { checkFrequency: codePush.CheckFrequency.ON_APP_RESUME, installMode: codePush.InstallMode.ON_NEXT_RESTART };

class NowSetup extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			store: configureStore({}, () => this.setState({ isLoading: false })),
			isLoading: true,
		};
	}
	render() {
		let mainApp = null;

		if (!this.state.isLoading) {
			mainApp = <nowucsandiego />;
		}
		return (
			<Provider store={this.state.store}>
				{mainApp}
			</Provider>
		);
	}
}

NowSetup = codePush(codePushOptions)(NowSetup);
module.exports = NowSetup;
