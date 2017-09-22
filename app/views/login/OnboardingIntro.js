import React from 'react';
import { View, ScrollView, Text, Image } from 'react-native';
import { connect } from 'react-redux';
import OnboardingLogin from './OnboardingLogin';
import { Actions } from 'react-native-router-flux';
import Touchable from '../common/Touchable';
import css from '../../styles/css';

class OnboardingIntro extends React.Component {
	constructor(props) {
		super(props);
		this.state = {

		};
	}
	
	render() {
		return (
			<View style={css.ob_container}>
				<Image style={css.ob_logo} source={require('../../assets/img/UCSanDiegoLogo-White.png')} />
				<Text style={[css.ob_introtext, css.ob_intro1]}>Hello.</Text>
				<Text style={[css.ob_introtext, css.ob_intro2]}>Enter your student SSO for a personalized experience.</Text>
				<Touchable onPress={() => Actions.OnboardingLogin()}>
					<Text style={[css.ob_introtext, css.ob_continue]}>Let's do it.</Text>
				</Touchable>
				<Touchable onPress={() => Actions.Home()}>
					<Text style={[css.ob_introtext, css.ob_skip]}>Skip for now.</Text>
				</Touchable>
			</View>
		);
	}
}


export default OnboardingIntro;
