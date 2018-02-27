import React from 'react';
import {
	Alert,
	View,
	Text,
	Image,
	ActivityIndicator,
	TextInput,
	TouchableWithoutFeedback
} from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';
import Toast from 'react-native-simple-toast';
import { openURL, hideKeyboard } from '../../util/general';
import AppSettings from '../../AppSettings';
import Touchable from '../common/Touchable';
import css from '../../styles/css';
import { COLOR_DGREY } from '../../styles/ColorConstants';

const campusLogo = require('../../assets/img/UCSanDiegoLogo-White.png');

class OnboardingLogin extends React.Component {
	componentWillReceiveProps(nextProps) {
		if (nextProps.user.isLoggedIn) {
			Toast.showWithGravity(
				'Successfully signed in!',
				Toast.SHORT,
				Toast.BOTTOM
			);

			this.props.setOnboardingViewed(true);
			Actions.Home();
		}
	}

	onSubmit = (username, password) => {
		this.props.doLogin(username, password);
	}

	render() {
		const { error } = this.props.user;
		if (error
			&& this.props.scene.name === 'OnboardingLogin'
			&& !this.props.user.isLoggingIn
		) {
			Alert.alert(
				'Sign in error',
				error,
				[
					{ text: 'OK', onPress: () => { this.props.clearErrors(); } }
				],
				{ cancelable: false }
			);
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
										placeholder="User ID / PID"
										placeholderTextColor={COLOR_DGREY}
										autoCapitalize="none"
										autoCorrect={false}
										returnKeyType="next"
										autoFocus={true}
										onChange={(event) => {
											this._usernameText = event.nativeEvent.text;
										}}
										onSubmitEditing={(event) => {
											this.passInput.focus();
										}}
									/>
									<TextInput
										style={[css.ob_input, css.ob_pass]}
										ref={(input) => { this.passInput = input; }}
										placeholder="Password / PAC"
										placeholderTextColor={COLOR_DGREY}
										autoCapitalize="none"
										secureTextEntry={true}
										returnKeyType="send"
										onChange={(event) => {
											this._passwordText = event.nativeEvent.text;
										}}
										onSubmitEditing={() => this.onSubmit(this._usernameText, this._passwordText)}
									/>

									<View style={css.ob_actionscontainer}>
										<Touchable style={css.ob_actions} onPress={() => openURL(AppSettings.FORGOT_PASSWORD_URL)}>
											<Text style={css.ob_forgotpass}>Forgot password?</Text>
										</Touchable>
										<Touchable style={css.ob_actions} onPress={() => { Actions.pop(); }}>
											<Text style={css.ob_cancel}>Cancel</Text>
										</Touchable>
									</View>
								</View>
							)
						}
					</View>
				</View>
			</TouchableWithoutFeedback>
		);
	}
}

const mapStateToProps = (state, props) => (
	{
		scene: state.routes.scene,
		user: state.user
	}
);

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		setOnboardingViewed: (viewed) => {
			dispatch({ type: 'SET_ONBOARDING_VIEWED', viewed });
		},
		doLogin: (username, password) => {
			dispatch({ type: 'USER_LOGIN', username, password });
		},
		doTokenRefresh: () => {
			dispatch({ type: 'USER_TOKEN_REFRESH' });
		},
		doLogout: () => {
			dispatch({ type: 'USER_LOGOUT' });
		},
		clearErrors: () => {
			dispatch({ type: 'USER_CLEAR_ERRORS' });
		}
	}
);

export default connect(mapStateToProps, mapDispatchToProps)(OnboardingLogin);
