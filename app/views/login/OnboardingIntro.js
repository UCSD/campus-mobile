import React from 'react';
import { View, Text, Image } from 'react-native';
import { connect } from 'react-redux';
import { Actions } from 'react-native-router-flux';
import Touchable from '../common/Touchable';
import css from '../../styles/css';

const campusLogo = require('../../assets/img/UCSanDiegoLogo-White.png');

class OnboardingIntro extends React.Component {
	constructor(props) {
		super(props);
		this.state = {

		};
	}

	componentWillMount() {
		if (this.props.onBoardingViewed) Actions.Home();
	}

	skipSSO = () => {
		this.props.setOnboardingViewed(true);
		Actions.Home();
	}

	render() {
		return (
			<View style={css.ob_container}>
				<Image style={css.ob_logo} source={campusLogo} />
				<Text style={[css.ob_introtext, css.ob_intro1]}>Hello.</Text>
				<Text style={[css.ob_introtext, css.ob_intro2]}>Enter your login for a personalized experience.</Text>
				<Touchable onPress={() => Actions.OnboardingLogin()}>
					<Text style={[css.ob_introtext, css.ob_continue]}>Let&#39;s do it.</Text>
				</Touchable>
				<Touchable onPress={() => this.skipSSO()}>
					<Text style={[css.ob_introtext, css.ob_skip]}>Skip for now.</Text>
				</Touchable>
			</View>
		);
	}
}

const mapStateToProps = (state, props) => (
	{
		scene: state.routes.scene,
		onBoardingViewed: state.routes.onBoardingViewed
	}
);

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		setOnboardingViewed: (viewed) => {
			dispatch({ type: 'SET_ONBOARDING_VIEWED', viewed });
		}
	}
);

export default connect(mapStateToProps, mapDispatchToProps)(OnboardingIntro);
