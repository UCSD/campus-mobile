import React from 'react'
import {
	Alert,
	View,
	Text,
	Image,
	ActivityIndicator,
	TextInput,
	TouchableWithoutFeedback
} from 'react-native'
import { connect } from 'react-redux'
import Toast from 'react-native-simple-toast'
import {
	openURL,
	hideKeyboard
} from '../../util/general'
import AppSettings from '../../AppSettings'
import Touchable from '../common/Touchable'
import css from '../../styles/css'
import { COLOR_DGREY } from '../../styles/ColorConstants'

const auth = require('../../util/auth')

const campusLogo = require('../../assets/images/UCSanDiegoLogo-nav.png')

class OnboardingLogin extends React.Component {
	componentDidMount() {
		// if we're mounting and we're somehow still in the
		// process of logging in, check if we've timed out.
		// otherwise, set a timeout
		if (this.props.user.isLoggingIn) {
			const now = new Date()
			const lastPostTime = new Date(this.props.user.timeRequested)
			if (now - lastPostTime >= AppSettings.SSO_TTL) {
				this.props.timeoutLogin()
			} else {
				// timeout after remaining time expires
				setTimeout(this.props.timeoutLogin, now - lastPostTime)
			}
		}
	}

	componentWillReceiveProps(nextProps) {
		if (nextProps.user.isLoggedIn) {
			Toast.showWithGravity(
				'Successfully signed in!',
				Toast.SHORT,
				Toast.BOTTOM
			)

			this.props.doTokenRefresh()
			auth.retrieveAccessToken()
				.then((token) => {
					console.log('User Data: ', this.props.user)
					console.log('Access Token: ', token)
				})

			this.props.setOnboardingViewed(true)
		}
	}

	Submit = (username, password) => {
		this.props.doLogin(username, password)
	}

	skipSSO = () => {
		this.props.setOnboardingViewed(true)
	}

	render() {
		const { error } = this.props.user
		if (error && !this.props.user.isLoggingIn) {
			Alert.alert(
				'Sign in error',
				error,
				[
					{
						text: 'OK',
						onPress: () => { this.props.clearErrors() }
					}
				],
				{ cancelable: false }
			)
		}

		return (
			<TouchableWithoutFeedback onPress={() => hideKeyboard()}>
				<View style={css.ob_container}>
					<Image style={css.ob_logo} source={campusLogo} />

					<View style={css.ob_logincontainer}>
						{(this.props.user.isLoggingIn) ?
							(
								<View style={css.ob_logincontainer}>
									<ActivityIndicator
										size="large"
										color="#fff"
										style={css.ob_loading_icon}
									/>
								</View>
							) : (
								<View style={css.ob_logincontainer}>
									<TextInput
										style={[css.ob_input, css.ob_login]}
										placeholder="User ID"
										placeholderTextColor={COLOR_DGREY}
										autoCapitalize="none"
										autoCorrect={false}
										returnKeyType="next"
										autoFocus={true}
										onChange={(event) => {
											this._usernameText = event.nativeEvent.text
										}}
										onSubmitEditing={(event) => {
											this.passInput.focus()
										}}
									/>
									<TextInput
										style={[css.ob_input, css.ob_pass]}
										ref={(input) => { this.passInput = input }}
										placeholder="Password"
										placeholderTextColor={COLOR_DGREY}
										autoCapitalize="none"
										secureTextEntry={true}
										returnKeyType="send"
										onChange={(event) => {
											this._passwordText = event.nativeEvent.text
										}}
										onSubmitEditing={() => this.onSubmit(this._usernameText, this._passwordText)}
									/>

									<View style={css.ob_actionscontainer}>
										<Touchable style={css.ob_actions} onPress={() => openURL(AppSettings.FORGOT_PASSWORD_URL)}>
											<Text style={css.ob_forgotpass}>Forgot password?</Text>
										</Touchable>
										<Touchable style={css.ob_actions} onPress={() => this.skipSSO()}>
											<Text style={css.ob_cancel}>Cancel</Text>
										</Touchable>
									</View>
								</View>
							)
						}
					</View>
				</View>
			</TouchableWithoutFeedback>
		)
	}
}

const mapStateToProps = (state, props) => (
	{
		user: state.user,
		onBoardingViewed: state.routes.onBoardingViewed
	}
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		setOnboardingViewed: (viewed) => {
			dispatch({
				type: 'SET_ONBOARDING_VIEWED',
				viewed
			})
		},
		doLogin: (username, password) => {
			dispatch({ type: 'USER_LOGIN', username, password })
		},
		doTokenRefresh: () => {
			dispatch({ type: 'USER_TOKEN_REFRESH' })
		},
		doLogout: () => {
			dispatch({ type: 'USER_LOGOUT' })
		},
		timeoutLogin: () => {
			dispatch({ type: 'USER_LOGIN_TIMEOUT' })
		},
		clearErrors: () => {
			dispatch({ type: 'USER_CLEAR_ERRORS' })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(OnboardingLogin)
