import React from 'react';
import {
	AsyncStorage
} from 'react-native';

import InfoModal from './common/InfoModal';

const AppSettings = require('../AppSettings');

// Handles showing a welcome modal to first time visitors
export default class WelcomeModal extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			modalVisible: false
		};
	}

	componentWillMount() {
		AsyncStorage.getItem('MODAL_ENABLED').then((value) => {
			if (value === 'false') {
				this.setState({ 'modalVisible': false });
			} else {
				this.setState({ 'modalVisible': true });
			}
		}).done();
	}

	setModalVisible = (visible) => {
		if (visible === 'false') {
			AsyncStorage.setItem('MODAL_ENABLED', 'false');
			this.setState({ 'modalVisible': false });
		}
	}

	render() {
		return (
			<InfoModal modalVisible={this.state.modalVisible} title={'Hello.'} onPress={() => this.setModalVisible('false')} buttonText={'ok, let\'s go already'}>
				Thanks for trying {AppSettings.APP_NAME}!{'\n\n'}
				{AppSettings.APP_NAME} connects you to campus with:{'\n\n'}
				- live shuttle information and maps{'\n'}
				- menus and dining info{'\n'}
				- timely news and events{'\n'}
				- links to campus services and apps{'\n'}
				- and we&apos;ll be adding new stuff all the time{'\n'}
			</InfoModal>
		);
	}
}
