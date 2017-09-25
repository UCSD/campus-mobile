import React from 'react';
import { View, ScrollView, Text, Image, TextInput, TouchableWithoutFeedback } from 'react-native';
import { connect } from 'react-redux';
import OnboardingLogin from './OnboardingLogin';
import { openURL, hideKeyboard } from '../../util/general';
import AppSettings from '../../AppSettings';
import { Actions } from 'react-native-router-flux';
import Touchable from '../common/Touchable';
import css from '../../styles/css';
import { COLOR_DGREY } from '../../styles/ColorConstants';

class OnboardingIntro extends React.Component {
	constructor(props) {
		super(props);
		this.state = {

		};
	}
	
	render() {
		return (
			<TouchableWithoutFeedback onPress={() => hideKeyboard()}>
				<View style={css.ob_container}>
					<Image style={css.ob_logo} source={require('../../assets/img/UCSanDiegoLogo-White.png')} />
					
					<View style={css.ob_logincontainer}>
						<TextInput
							style={[css.ob_input, css.ob_login]}
							placeholder={'User ID / PID'}
							placeholderTextColor={COLOR_DGREY}
							autoCapitalize={'none'}
							returnKeyType={'next'}
							autoFocus={true}
							onSubmitEditing={(event) => {
								this.refs.passInput.focus();
							}}
						/>
						<TextInput
							style={[css.ob_input, css.ob_pass]}
							ref={'passInput'}
							placeholder={'Password / PAC'}
							placeholderTextColor={COLOR_DGREY}
							autoCapitalize={'none'}
							secureTextEntry={true}
							returnKeyType={'send'}
							onSubmitEditing={() => this.onSubmit()}
						/>

						<View style={css.ob_actionscontainer}>
							<Touchable style={css.ob_actions} onPress={() => openURL(AppSettings.FORGOT_AD_PASSWORD_URL)}>
								<Text style={css.ob_forgotpass}>Forgot password?</Text>
							</Touchable>
							<Touchable style={css.ob_actions} onPress={() => Actions.Home()}>
								<Text style={css.ob_cancel}>Cancel</Text>
							</Touchable>
						</View>
					</View>
				</View>
			</TouchableWithoutFeedback>
		);
	}

	onSubmit() {
		Actions.Home();
	}
}


export default OnboardingIntro;
