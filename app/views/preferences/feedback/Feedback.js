import React, { Component } from 'react'
import {
	Text,
	View,
	ActivityIndicator,
	TextInput,
	Alert,
	TouchableWithoutFeedback,
	TouchableOpacity,
	ScrollView,
	KeyboardAvoidingView
} from 'react-native'
import { connect } from 'react-redux'
import Toast from 'react-native-simple-toast'
import { hideKeyboard } from '../../../util/general'
import logger from '../../../util/logger'
import css from '../../../styles/css'
import { APP_NAME, REQUEST_POST_TTL } from '../../../AppSettings'

export class FeedbackView extends Component {
	componentDidMount() {
		logger.ga('View Loaded: Feedback')

		// if we're mounting and we're somehow still in the
		// process of POSTing, check if we've timed out.
		// otherwise, set a timeout
		if (this.props.requestStatus) {
			const now = new Date()
			const lastPostTime = new Date(this.props.requestStatus.timeRequested)
			const e = new Error('Request timed out.')
			if (now - lastPostTime >= REQUEST_POST_TTL) {
				this.props.timeoutFeedback(e)
			} else {
				// timeout after remaining time expires
				setTimeout(() => { this.props.timeoutFeedback(e) }, now - lastPostTime)
			}
		}
	}

	componentDidUpdate(prevProps, prevState) {
		const oldStatus = prevProps.requestStatus
		const newStatus = this.props.requestStatus

		// Only render alerts if status change is new
		if (oldStatus !== newStatus) {
			// Successful feedback submission
			if (this.props.feedback.response) {
				Toast.showWithGravity(
					'Thanks, your feedback was submitted!',
					Toast.LONG,
					Toast.BOTTOM
				)
			}

			// Failed feedback submission
			if (this.props.requestError) {
				Alert.alert(
					'Feedback Submission Error',
					'Unfortunately, there was an error submitting your feedback. Please try again later.'
				)
			}
		}
	}

	_postFeedback() {
		if (this.props.feedback.comment !== '') {
			this.props.postFeedback(this.props.feedback)
		} else {
			Toast.showWithGravity(
				'Please complete the required field.',
				Toast.SHORT,
				Toast.BOTTOM
			)
		}
	}

	handleFeedbackInput = fieldName => (e) => {
		const { comment, name, email } = this.props.feedback
		const newFeedback = { comment, name, email }
		newFeedback[fieldName] = e.nativeEvent.text

		this.props.updateFeedback(newFeedback)
	}

	_renderFormView() {
		return (
			<KeyboardAvoidingView style={css.main} behavior="padding" enabled>
				<TouchableWithoutFeedback onPress={() => hideKeyboard()}>
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
								style={css.feedback_text_input}
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
				</TouchableWithoutFeedback>
			</KeyboardAvoidingView>
		)
	}

	render() {
		if (this.props.requestStatus) {
			return (
				<ScrollView>
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
				</ScrollView>
			)
		} else {
			return this._renderFormView()
		}
	}
}

const mapStateToProps = (state, props) => (
	{
		feedback: state.feedback,
		requestStatus: state.requestStatuses.POST_FEEDBACK,
		requestError: state.requestErrors.POST_FEEDBACK
	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		updateFeedback: (feedback) => {
			dispatch({ type: 'UPDATE_FEEDBACK', feedback })
		},
		postFeedback: (feedback) => {
			dispatch({ type: 'POST_FEEDBACK', feedback })
		},
		timeoutFeedback: (error) => {
			dispatch({ type: 'POST_FEEDBACK_FAILURE', error })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(FeedbackView)
