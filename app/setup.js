import React from 'react';
import { View, StatusBar, Alert, AsyncStorage } from 'react-native';
import { setJSExceptionHandler } from 'react-native-exception-handler';
import RNExitApp from 'react-native-exit-app';

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
			store: configureStore({}, this.finishLoading),
			isLoading: true,
		};
	}

	finishLoading = () => {
		this.setState({ isLoading: false });

		const errorHandler = (e, isFatal) => {
			if (isFatal) {
				AsyncStorage.clear();
				Alert.alert(
					'Unexpected error occurred',
					'Please try restarting the app. If the app is still crashing, please keep an eye out for an update or try again later.',
					/*`
					Error: ${(isFatal) ? 'Fatal:' : ''} ${e.name} ${e.message}

					We will need to restart the app.
					`,*/
					[{
						text: 'Okay',
						onPress: () => {
							RNExitApp.exitApp();
						}
					}]
				);
			} else {
				console.log(e); // So that we can see it in the ADB logs in case of Android if needed
			}
		};

		setJSExceptionHandler(errorHandler, true);
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
