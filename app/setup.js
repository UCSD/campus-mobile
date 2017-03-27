import React from 'react';
import { View } from 'react-native';

// CODE PUSH
import codePush from 'react-native-code-push';

// REDUX
import { Provider } from 'react-redux';
import configureStore from './store/configureStore';

import Main from './main';

const codePushOptions = { checkFrequency: codePush.CheckFrequency.ON_APP_RESUME, installMode: codePush.InstallMode.ON_NEXT_RESTART };

class CampusMobileSetup extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			store: configureStore({}, () => this.setState({ isLoading: false })),
			isLoading: true,
		};
	}
	render() {
		let mainApp = <View />;

		if (!this.state.isLoading) {
			mainApp = <Main />;
		}
		return (
			<Provider store={this.state.store}>
				{mainApp}
			</Provider>
		);
	}
}

CampusMobileSetup = codePush(codePushOptions)(CampusMobileSetup);
module.exports = CampusMobileSetup;
