import React, { Component } from 'react';
import {
	Text,
	View,
	TouchableHighlight,
	InteractionManager,
	ActivityIndicator,
	TextInput,
	StyleSheet,
	Alert,
	TouchableWithoutFeedback,
} from 'react-native';

import { getPRM, round, getCampusPrimary } from '../util/general';

const css = require('../styles/css');
const general = require('../util/general');
const logger = require('../util/logger');
const AppSettings = require('../AppSettings');

export default class FeedbackView extends Component {

	constructor(props) {
		super(props);

		this.state = {
			commentsText: '',
			nameText: '',
			emailText: '',
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

	/**
	 * Called after state change
	 * @return bool whether the component should re-render.
	**/
	shouldComponentUpdate(nextProps, nextState) {
		return true;
	}

	_postFeedback() {
		if (this.state.commentsText !== '') {
			const formData = new FormData();
			formData.append('element_1', this.state.commentsText);
			formData.append('element_2', this.state.nameText);
			formData.append('element_3', this.state.emailText);
			formData.append('form_id','175631');
			formData.append('submit_form','1');
			formData.append('page_number','1');
			formData.append('submit_form','Submit');

			fetch('https://eforms.ucsd.edu/view.php?id=175631', {
				method: 'POST',
				body: formData
			})
			.then((response) => {
				Alert.alert(
					'Thank you!',
					'We will take your feedback into consideration as we continue developing and improving the app.',
				);

				this.setState({
					submit: true,
					commentsText: '',
					nameText: '',
					emailText: '',
				});
			})
			.then((responseJson) => {
				// logger.log(responseJson);
			})
			.catch((error) => {
				// logger.error(error);
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
					style={styles.loading_icon}
					size="large"
				/>
			</View>
		);
	}

	_renderFormView() {
		return (
			<TouchableWithoutFeedback onPress={() => general.hideKeyboard()}>
				<View style={css.main_container}>
					<View style={styles.feedback_container}>
						<Text style={styles.feedback_label}>
							Help us make the {AppSettings.APP_NAME} app better.{'\n'}
							Submit your thoughts and suggestions.
						</Text>


						<View style={styles.text_container}>
							<TextInput
								ref={(ref) => { this._name = ref; }}
								value={this.state.nameText}
								onChangeText={(text) => this.setState({ nameText: text })}
								placeholder="Name"
								underlineColorAndroid={'transparent'}
								style={styles.feedback_text}
								returnKeyType={'next'}
								onSubmitEditing={() => this._email.focus()}
							/>
						</View>

						<View style={styles.text_container}>
							<TextInput
								ref={(ref) => { this._email = ref; }}
								value={this.state.emailText}
								onChangeText={(text) => this.setState({ emailText: text })}
								placeholder="Email"
								underlineColorAndroid={'transparent'}
								style={styles.feedback_text}
								returnKeyType={'next'}
								keyboardType={'email-address'}
								onSubmitEditing={() => this._feedback.focus()}
							/>
						</View>

						<View style={styles.feedback_text_container}>
							<TextInput
								ref={(ref) => { this._feedback = ref; }}
								multiline={true}
								blurOnSubmit={true}
								value={this.state.commentsText}
								onChangeText={(text) => this.setState({ commentsText: text })}
								placeholder="Tell us what you think*"
								underlineColorAndroid={'transparent'}
								style={styles.feedback_text}
								returnKeyType={'send'}
								onSubmitEditing={() => this._postFeedback()}
							/>
						</View>

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

const styles = StyleSheet.create({
	loading_icon: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	feedback_container: { flexDirection: 'column', marginHorizontal: 8, marginTop: 8 },
	feedback_label: { flexWrap: 'wrap', fontSize: round(19 * getPRM()), paddingBottom: 16, lineHeight: 24 },
	feedback_text: { backgroundColor: '#FFF', flex:1, fontSize: round(20 * getPRM()), alignItems: 'center', padding: 8 },

	submit_container: { justifyContent: 'center', alignItems: 'center', backgroundColor: getCampusPrimary(), borderRadius: 3, padding: 10 },
	submit_text: { fontSize: round(16 * getPRM()), color: '#FFF' },

	feedback_text_container: { height: round(100 * getPRM()), borderColor: '#DADADA', borderBottomWidth: 1, marginBottom: 8 },
	text_container: { height: round(50 * getPRM()), borderColor: '#DADADA', borderBottomWidth: 1, marginBottom: 8 },
});
