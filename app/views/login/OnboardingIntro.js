import React from 'react'
import {
	View,
	Text,
	Image
} from 'react-native'
import { connect } from 'react-redux'
import Touchable from '../common/Touchable'
import css from '../../styles/css'

const campusLogo = require('../../assets/images/UCSanDiegoLogo-nav.png')

class OnboardingIntro extends React.Component {
	skipSSO = () => {
		this.props.setOnboardingViewed(true)
	}

	render() {
		return (
			<View style={css.ob_container}>
				<Image style={css.ob_logo} source={campusLogo} />
				<Text style={[css.ob_introtext, css.ob_intro1]}>Hello.</Text>
				<Text style={[css.ob_introtext, css.ob_intro2]}>Enter your login for a personalized experience.</Text>
				<Touchable onPress={() => { this.props.navigation.navigate('OnboardingLogin') }}>
					<Text style={[css.ob_introtext, css.ob_continue]}>Let&#39;s do it.</Text>
				</Touchable>
				<Touchable onPress={() => this.skipSSO()}>
					<Text style={[css.ob_introtext, css.ob_skip]}>Skip for now.</Text>
				</Touchable>
			</View>
		)
	}
}

const mapStateToProps = (state, props) => (
	{ onBoardingViewed: state.routes.onBoardingViewed }
)

const mapDispatchToProps = (dispatch, ownProps) => (
	{
		setOnboardingViewed: (viewed) => {
			dispatch({
				type: 'SET_ONBOARDING_VIEWED',
				viewed
			})
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(OnboardingIntro)
