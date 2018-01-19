import React, { Component } from 'react';
import {
	Text,
	View,
	ActivityIndicator,
	TextInput,
	Alert,
	TouchableWithoutFeedback,
	TouchableOpacity
} from 'react-native';
import { connect } from 'react-redux';
import Toast from 'react-native-simple-toast';
import { hideKeyboard } from '../../util/general';
import logger from '../../util/logger';
import css from '../../styles/css';
import { APP_NAME, FEEDBACK_POST_TTL } from '../../AppSettings';

class FeedbackView extends Component {
	componentDidMount() {
		logger.ga('View Loaded: Feedback');

		// if we're mounting and we're somehow still in the
		// process of POSTing, check if we've timed out.
		// otherwise, set a timeout
		if (this.props.feedback.status.requesting) {
			const now = new Date();
			const lastPostTime = new Date(this.props.feedback.status.timeRequested);
			if (now - lastPostTime >= FEEDBACK_POST_TTL) {
				this.props.timeoutFeedback();
			} else {
				// timeout after remaining time expires
				setTimeout(this.props.timeoutFeedback, now - lastPostTime);
			}
		}
	}

	componentDidUpdate(prevProps, prevState) {
		const oldStatus = prevProps.feedback.status;
		const newStatus = this.props.feedback.status;

		// Only render alerts if status change is new
		if (oldStatus !== newStatus) {
			// Successful feedback submission
			if (newStatus.response) {
				Alert.alert(
					'Thank you!',
					'We will take your feedback into consideration as we continue developing and improving the app.'
				);
			}

			// Failed feedback submission
			if (newStatus.error) {
				Toast.showWithGravity(
					'Unfortunately, there was an error submitting your feedback. Please try again later.',
					Toast.LONG,
					Toast.BOTTOM
				);
			}
		}
	}

	_postFeedback() {
		if (this.props.feedback.comment !== '') {
			this.props.postFeedback(this.props.feedback);
		}
		else {
			Toast.showWithGravity(
				'Please complete the required field.',
				Toast.SHORT,
				Toast.BOTTOM
			);
		}
	}

	handleFeedbackInput = fieldName => (e) => {
		const {
			comment, name, email, commentHeight
		} = this.props.feedback;
		const newFeedback = {
			comment, name, email, commentHeight
		};
		newFeedback[fieldName] = e.nativeEvent.text;

		if (fieldName === 'comment') {
			if (this.props.feedback.commentHeight !== e.nativeEvent.contentSize.height) {
				newFeedback.commentHeight = e.nativeEvent.contentSize.height;
			}
		}

		this.props.updateFeedback(newFeedback);
	}

	_renderFormView() {
		return (
			<TouchableWithoutFeedback
				onPress={() => hideKeyboard()}
			>
				<View style={css.main_container}>
					<View style={css.feedback_container}>
						<Text style={css.feedback_label}>
							Help us make the {APP_NAME} app better.
						</Text>
						<Text style={css.feedback_label}>
							Submit your thoughts and suggestions here.
						</Text>

						<View style={css.feedback_comments_text_container}>
							<TextInput
								multiline={true}
								blurOnSubmit={true}
								value={this.props.feedback.comment}
								onChange={this.handleFeedbackInput('comment')}
								placeholder="Tell us what you think*"
								underlineColorAndroid="transparent"
								style={[css.feedback_text_input, { height: Math.max(50, this.props.feedback.commentHeight) }]}
								returnKeyType="done"
								maxLength={500}
							/>
						</View>

						<View style={css.feedback_email_text_container}>
							<TextInput
								value={this.props.feedback.email}
								onChange={this.handleFeedbackInput('email')}
								placeholder="Email"
								underlineColorAndroid="transparent"
								style={css.feedback_text_input}
								returnKeyType="done"
								keyboardType="email-address"
								autoCapitalize="none"
								maxLength={100}
							/>
						</View>

						<TouchableOpacity underlayColor="rgba(200,200,200,.1)" onPress={() => this._postFeedback()}>
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
		if (this.props.feedback.status.requesting) {
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
		} else {
			return this._renderFormView();
		}
	}
}

const mapStateToProps = (state, props) => (
	{
		feedback: state.feedback,
		scene: state.routes.scene
	}
);

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		updateFeedback: (feedback) => {
			dispatch({ type: 'UPDATE_FEEDBACK_STATE', feedback });
		},
		postFeedback: (feedback) => {
			dispatch({ type: 'FEEDBACK_POST_REQUESTED', feedback });
		},
		timeoutFeedback: () => {
			dispatch({ type: 'FEEDBACK_POST_TIMEOUT' });
		}
	}
);

module.exports = connect(mapStateToProps, mapDispatchToProps)(FeedbackView);
