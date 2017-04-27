import React from 'react';
import { View, StatusBar } from 'react-native';

// CODE PUSH
import codePush from 'react-native-code-push';

// REDUX
import { Provider } from 'react-redux';
import configureStore from './store/configureStore';

import Main from './main';
import general from './util/general';

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
		if (general.platformIOS()) {
			StatusBar.setBarStyle('light-content');
		} else if (general.platformAndroid()) {
			StatusBar.setBackgroundColor('#101d32', false);
		}

		let mainApp = <View />;

		if (this.state.isLoading) {
			return (
				<View />
			);
		} else {
			return (
				<Provider store={this.state.store}>
					<Main />
				</Provider>
			);
		}
	}
}

CampusMobileSetup = codePush(codePushOptions)(CampusMobileSetup);
module.exports = CampusMobileSetup;
