import React, { Component } from 'react';
import {
	Text,
	View,
	InteractionManager,
	ActivityIndicator,
	TextInput,
	Alert,
	TouchableWithoutFeedback,
	TouchableOpacity
} from 'react-native';
import { connect } from 'react-redux';
import Device from 'react-native-device-info';
import Toast from 'react-native-simple-toast';
import { hideKeyboard } from '../util/general';
import logger from '../util/logger';
import css from '../styles/css';
import AppSettings from '../AppSettings';

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
				if (response.status !== 200) {
					const e = new Error('Invalid response from server.');
					throw e;
				}

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
			})
			.catch((error) => {
				logger.log('Error submitting Feedback: ' + error);
				this.setState({
					loaded: true
				}, () => {
					Toast.showWithGravity(
						'Unfortunately, there was an error submitting your feedback. Please try again.',
						Toast.SHORT,
						Toast.BOTTOM
					);
				});
			});
		}
		else {
			Toast.showWithGravity(
				'Please complete the required field.',
				Toast.SHORT,
				Toast.BOTTOM
			);
			return;
		}
	}

	_renderLoadingView() {
		return (
			<View style={css.main_container}>
				<View style={css.feedback_submitting_container}>
					<ActivityIndicator
						animating={true}
						style={css.feedback_loading_icon}
						size="large"
					/>
					<Text style={css.feedback_submitting_text}>
						Your feedback is being submitted...
					</Text>
				</View>
			</View>
		);
	}

	_renderFormView() {
		return (
			<TouchableWithoutFeedback
				onPress={() => hideKeyboard()}
			>
				<View style={css.main_container}>
					<View style={css.feedback_container}>
						<Text style={css.feedback_label}>
							Help us make the {AppSettings.APP_NAME} app better.
						</Text>
						<Text style={css.feedback_label}>
							Submit your thoughts and suggestions here.
						</Text>

						<View style={css.feedback_comments_text_container}>
							<TextInput
								ref={(ref) => { this._feedback = ref; }}
								multiline={true}
								blurOnSubmit={true}
								value={this.state.commentsText}
								onChange={(event) => {
									this.setState({
										commentsText: event.nativeEvent.text,
										commentsHeight: event.nativeEvent.contentSize.height,
									});
								}}
								placeholder="Tell us what you think*"
								underlineColorAndroid={'transparent'}
								style={[css.feedback_text_input, { height: Math.max(50, this.state.commentsHeight) }]}
								returnKeyType={'done'}
								maxLength={500}
							/>
						</View>

						<View style={css.feedback_email_text_container}>
							<TextInput
								ref={(ref) => { this._email = ref; }}
								value={this.state.emailText}
								onChangeText={(text) => this.setState({ emailText: text })}
								placeholder="Email"
								underlineColorAndroid={'transparent'}
								style={css.feedback_text_input}
								returnKeyType={'done'}
								keyboardType={'email-address'}
								maxLength={100}
							/>
						</View>

						<TouchableOpacity underlayColor={'rgba(200,200,200,.1)'} onPress={() => this._postFeedback()}>
							<View style={css.feedback_submit_container}>
								<Text style={css.feedback_submit_text}>Submit</Text>
							</View>
						</TouchableOpacity>

					</View>
				</View>
			</TouchableWithoutFeedback>
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

const mapStateToProps = (state, props) => (
	{
		scene: state.routes.scene
	}
);

module.exports = connect(mapStateToProps)(FeedbackView);
