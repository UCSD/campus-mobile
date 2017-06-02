
import React, { Component } from 'react';
import {
	Text,
	View,
	InteractionManager,
	ActivityIndicator,
	TextInput,
	StyleSheet,
	Alert,
	TouchableWithoutFeedback,
	TouchableOpacity,
	KeyboardAvoidingView,
} from 'react-native';
import { connect } from 'react-redux';
import Device from 'react-native-device-info';

import Touchable from './common/Touchable';
import { hideKeyboard } from '../util/general';
import logger from '../util/logger';
import css from '../styles/css';
import AppSettings from '../AppSettings';
import {
	COLOR_WHITE,
	COLOR_PRIMARY
} from '../styles/ColorConstants';

class FeedbackView extends Component {

	constructor(props) {
		super(props);

		this.state = {
			commentsText: '',
			nameText: '',
			emailText: '',
			commentsHeight: 0,
			loaded: false,
			submit: false,
		};
	}

	componentDidMount() {
		logger.ga('View Loaded: Feedback');

		InteractionManager.runAfterInteractions(() => {
			this.setState({ loaded: true });
		});
	}

	componentWillReceiveProps(nextProps) {
		// Clear search results when navigating away
		if (nextProps.scene.key !== this.props.scene.key) {
			this.setState({
				commentsText: '',
				nameText: '',
				emailText: '',
			});
		}
	}

	/**
	 * Called after state change
	 * @return bool whether the component should re-render.
	**/
	shouldComponentUpdate(nextProps, nextState) {
		return true;
	}

	_postFeedback() {
		if (this.state.commentsText !== '') {
			this.setState({ loaded: false });

			const formData = new FormData();
			formData.append('element_1', this.state.commentsText);
			formData.append('element_2', this.state.nameText);
			formData.append('element_3', this.state.emailText);
			formData.append(
				'element_4',
				'Device Manufacturer: ' + Device.getManufacturer() + '\n' +
				'Device Brand: ' + Device.getBrand() + '\n' +
				'Device Model: ' + Device.getModel() + '\n' +
				'Device ID: ' + Device.getDeviceId() + '\n' +
				'System Name: ' + Device.getSystemName() + '\n' +
				'System Version: ' + Device.getSystemVersion() + '\n' +
				'Bundle ID: ' + Device.getBundleId() + '\n' +
				'App Version: ' + Device.getVersion() + '\n' +
				'Build Number: ' + Device.getBuildNumber() + '\n' +
				'Device Name: ' + Device.getDeviceName() + '\n' +
				'User Agent: ' + Device.getUserAgent() + '\n' +
				'Device Locale: ' + Device.getDeviceLocale() + '\n' +
				'Device Country: ' + Device.getDeviceCountry() + '\n' +
				'Timezone: ' + Device.getTimezone()
			);
			formData.append('form_id','175631');
			formData.append('submit_form','1');
			formData.append('page_number','1');
			formData.append('submit_form','Submit');

			fetch('https://eforms.ucsd.edu/view.php?id=175631', {
				method: 'POST',
				body: formData
			})
			.then((response) => {
				// Clear fields and alert user
				Alert.alert(
					'Thank you!',
					'We will take your feedback into consideration as we continue developing and improving the app.',
				);

				this.setState({
					submit: true,
					commentsText: '',
					nameText: '',
					emailText: '',
					commentsHeight: 0,
					loaded: true
				});
				return response.json();
			})
			.then((responseJson) => {
				// logger.log(responseJson);
			})
			.catch((error) => {
				logger.log('Error submitting Feedback: ' + error);
			});
		}
		else {
			return;
		}
	}

	_renderLoadingView() {
		return (
			<View style={css.main_container}>
				<ActivityIndicator
					animating={true}
					style={styles.loadingIcon}
					size="large"
				/>
			</View>
		);
	}

	_renderFormView() {
		return (
			<KeyboardAvoidingView
				style={css.main_container}
				behavior="padding"
			>
				<TouchableWithoutFeedback
					onPress={() => hideKeyboard()}
				>
					<View
						style={{ flex: 1 }}
					>
						<Text style={styles.feedbackText}>
							{this.state.labelText}
						</Text>
						<TextInput
							ref={(ref) => { this._feedback = ref; }}
							multiline={true}
							blurOnSubmit={true}
							value={this.state.commentsText}
							onFocus={() => this.setState({
								labelText: ''
							})}
							onChange={(event) => {
								this.setState({
									commentsText: event.nativeEvent.text,
								});
							}}
							placeholder="Tell us what you think*"
							underlineColorAndroid={'transparent'}
							style={[styles.feedbackInput]}
							returnKeyType={'done'}
							maxLength={500}
						/>
						<TextInput
							ref={(ref) => { this._email = ref; }}
							value={this.state.emailText}
							onChangeText={(text) => this.setState({ emailText: text })}
							placeholder="Email"
							underlineColorAndroid={'transparent'}
							style={styles.emailInput}
							returnKeyType={'done'}
							keyboardType={'email-address'}
							maxLength={100}
						/>
						<Touchable
							onPress={() => this._postFeedback()}
						>
							<View style={styles.submitContainer}>
								<Text style={styles.submitText}>Submit</Text>
							</View>
						</Touchable>
					</View>
				</TouchableWithoutFeedback>
			</KeyboardAvoidingView>
		);
	}

	render() {
		// return this._renderSubmitView();
		if (!this.state.loaded) {
			return this._renderLoadingView();
		} else {
			return this._renderFormView();
		}
	}
}

const styles = StyleSheet.create({
	loadingIcon: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	feedbackText: { flexWrap: 'wrap', fontSize: 18, margin: 8, lineHeight: 24 },
	feedbackInput: { flex: 1, backgroundColor: COLOR_WHITE, fontSize: 18, alignItems: 'center', padding: 8, margin: 8, minHeight: 50 },
	emailInput: { backgroundColor: COLOR_WHITE, fontSize: 18, alignItems: 'center', padding: 8, margin: 8, minHeight: 50 },
	submitContainer: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLOR_PRIMARY, borderRadius: 3, padding: 10, margin: 8 },
	submitText: { fontSize: 16, color: COLOR_WHITE },
});

const mapStateToProps = (state, props) => (
	{
		scene: state.routes.scene
	}
);

export default connect(mapStateToProps)(FeedbackView);
