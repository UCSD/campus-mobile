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
import COLOR from '../../styles/ColorConstants'

const auth = require('../../util/auth')

const campusLogo = require('../../assets/images/UCSanDiegoLogo-White.png')

class OnboardingLogin extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			credentials: {
				username: '',
				password: ''
			}
		}
	}

	componentDidMount() {
		// if we're mounting and we're somehow still in the
		// process of logging in, check if we've timed out.
		// otherwise, set a timeout
		if (this.props.requestStatus) {
			const now = new Date()
			const lastPostTime = new Date(this.props.requestStatus.timeRequested)
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

			auth.retrieveAccessToken()
				.then((token) => {
					console.log('User Data: ', this.props.user)
					console.log('Access Token: ', token)
				})

			this.props.setOnboardingViewed(true)
		}
	}

	componentDidUpdate(prevProps, prevState) {
		const oldStatus = prevProps.requestStatus
		const newStatus = this.props.requestStatus

		// Only render alerts if status change is new
		if (oldStatus !== newStatus) {
			// Failed log in
			if (this.props.requestError) {
				Alert.alert(
					'Sign in error',
					this.props.requestError,
					{ cancelable: false }
				)
			}
		}
	}

	onSubmit = (username, password) => {
		this.props.doLogin(username, password)
	}

	handleCredentialInput = fieldName => (e) => {
		const { username, password } = this.state.credentials
		const newCredentials = { username, password }
		newCredentials[fieldName] = e.nativeEvent.text

		this.setState({ credentials: newCredentials })
	}

	skipSSO = () => {
		this.props.setOnboardingViewed(true)
	}

	render() {
		const { username, password } = this.state.credentials

		return (
			<TouchableWithoutFeedback onPress={() => hideKeyboard()}>
				<View style={css.ob_container}>
					<Image style={css.ob_logo} source={campusLogo} />

					<View style={css.ob_logincontainer}>
						{(this.props.requestStatus) ?
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
										value={username}
										placeholder="User ID"
										placeholderTextColor={COLOR.DGREY}
										underlineColorAndroid={COLOR.TRANSPARENT}
										autoCapitalize="none"
										autoCorrect={false}
										returnKeyType="next"
										autoFocus={true}
										onChange={this.handleCredentialInput('username')}
										onSubmitEditing={(event) => {
											this.passInput.focus()
										}}
									/>
									<TextInput
										style={[css.ob_input, css.ob_pass]}
										value={password}
										ref={(input) => { this.passInput = input }}
										placeholder="Password"
										placeholderTextColor={COLOR.DGREY}
										underlineColorAndroid={COLOR.TRANSPARENT}
										autoCapitalize="none"
										secureTextEntry={true}
										returnKeyType="send"
										onChange={this.handleCredentialInput('password')}
										onSubmitEditing={() => this.onSubmit(username, password)}
									/>

									<Touchable
										onPress={() => this.onSubmit(username, password)}
										style={css.ob_loginButton}
									>
										<Text style={css.ob_loginText}>Sign in</Text>
									</Touchable>

									<View style={css.ob_actionscontainer}>
										<Touchable style={css.ob_help_button} onPress={() => openURL(AppSettings.ACCOUNT_HELP_URL)}>
											<Text style={css.ob_forgotpass}>Need help logging in?</Text>
										</Touchable>
										<Touchable style={css.ob_cancel_button} onPress={() => this.skipSSO()}>
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
		onBoardingViewed: state.routes.onBoardingViewed,
		requestStatus: state.requestStatuses.LOG_IN,
		requestError: state.requestErrors.LOG_IN
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
		doLogout: () => {
			dispatch({ type: 'USER_LOGOUT' })
		},
		timeoutLogin: () => {
			dispatch({ type: 'USER_LOGIN_TIMEOUT' })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(OnboardingLogin)
