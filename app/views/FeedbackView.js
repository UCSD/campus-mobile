import React, { Component } from 'react';
import {
	Text,
	View,
	ScrollView,
	TouchableHighlight,
	InteractionManager,
	ActivityIndicator,
	TextInput,
	StyleSheet,
	Platform,
	Dimensions
} from 'react-native';

import { getPRM, getMaxCardWidth, round, getCampusPrimary } from '../util/general';

const css = require('../styles/css');
const logger = require('../util/logger');
const AppSettings = require('../AppSettings');
const deviceWidth = Dimensions.get('window').width;

export default class FeedbackView extends Component {

	constructor(props) {
		super(props);

		this.appInfo = AppSettings.APP_VERSION;
		if (AppSettings.APP_CODEPUSH_VERSION) {
			this.appInfo += '-cp' + AppSettings.APP_CODEPUSH_VERSION;
		}

		this.state = {
			commentsText: '',
			nameText: '',
			emailText: '',
			loaded: false,
			submit: false,
			appInfo: '',
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
				this.setState({ submit: true });
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
			<View style={css.main_container}>
				<ScrollView>
					<View style={styles.feedback_container}>
						<Text style={styles.feedback_label}>
							Help us make the UCSD app better. Submit your thoughts and suggestions.{'\n'}
						</Text>

						<View style={styles.feedback_text_container}>
							<TextInput
								multiline={true}
								onChangeText={(text) => this.setState({ commentsText: text })}
								placeholder="Tell us what you think*"
								style={styles.feedback_text}
							/>
						</View>

						<View style={styles.text_container}>
							<TextInput
								onChangeText={(text) => this.setState({ nameText: text })}
								placeholder="Name"
								style={styles.feedback_text}
							/>
						</View>

						<View style={styles.text_container}>
							<TextInput
								onChangeText={(text) => this.setState({ emailText: text })}
								placeholder="Email"
								style={styles.feedback_text}
							/>
						</View>

						<TouchableHighlight underlayColor={'rgba(200,200,200,.1)'} onPress={() => this._postFeedback()}>
							<View style={styles.submit_container}>
								<Text style={styles.submit_text}>Submit</Text>
							</View>
						</TouchableHighlight>
					</View>
				</ScrollView>
				<Text style={styles.feedback_appInfo}>v{this.appInfo}</Text>
			</View>
		);
	}

	_renderSubmitView() {
		return (
			<View style={css.main_container}>
				<ScrollView>
					<View style={styles.feedback_container}>
						<Text style={styles.feedback_label}>Thank you for your feedback!</Text>
					</View>
				</ScrollView>
			</View>
		);
	}

	render() {
		return this._renderFormView();
		if (!this.state.loaded) {
			return this._renderLoadingView();
		} else if (!this.state.submit) {
			return this._renderFormView();
		} else {
			return this._renderSubmitView();
		}
	}
}

const styles = StyleSheet.create({
	loading_icon: { flex: 1, alignItems: 'center', justifyContent: 'center' },
	feedback_container: { flex:1, alignItems: 'flex-start', flexDirection: 'column' },
	feedback_label: { flex: 1, flexWrap: 'wrap', fontSize: round(20 * getPRM()), height: round(80 * getPRM()), padding: 8 },
	feedback_text: { backgroundColor: '#FFF', flex:1, fontSize: round(20 * getPRM()), alignItems: 'center', padding: 8, },
	feedback_appInfo: { position: 'absolute', bottom: 0, right: 0, color: '#BBB', fontSize: 9, padding: 4 },

	submit_container: { width: deviceWidth, justifyContent: 'center', alignItems: 'center', backgroundColor: getCampusPrimary(), borderRadius: 3, padding: 10 },
	submit_text: { fontSize: round(16 * getPRM()), color: '#FFF' },

	feedback_text_container: { width: deviceWidth, height: round(100 * getPRM()), borderColor: '#DADADA', borderBottomWidth: 1, },
	text_container: { width: deviceWidth, height: round(50 * getPRM()), borderColor: '#DADADA', borderBottomWidth: 1, },
});
