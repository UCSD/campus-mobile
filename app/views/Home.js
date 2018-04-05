import React from 'react'
import { Image, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import { checkGooglePlayServices } from 'react-native-google-api-availability-bridge'

import WeatherCardContainer from './weather/WeatherCardContainer'
import ShuttleCardContainer from './shuttle/ShuttleCardContainer'
import EventCardContainer from './events/EventCardContainer'
import QuicklinksCardContainer from './quicklinks/QuicklinksCardContainer'
import NewsCardContainer from './news/NewsCardContainer'
import DiningCardContainer from './dining/DiningCardContainer'
import SpecialEventsCardContainer from './specialEvents/SpecialEventsCardContainer'
import { platformAndroid } from '../util/general'
import css from '../styles/css'
import logger from '../util/logger'

const campusLogoImage = require('../assets/img/UCSanDiegoLogo-White.png')

export class Home extends React.Component {
	static navigationOptions = {
		title: 'Home',
		headerTitle: <Image source={campusLogoImage} style={css.navCampusLogoTitle} />
	};

	constructor(props) {
		super(props)
		this.state = { updatedGoogle: true }
	}

	componentWillMount() {
		if (platformAndroid()) {
			this.updateGooglePlay()
		}
	}

	componentDidMount() {
		logger.ga('View Loaded: Home')
		this._cards = []

		if (this._scrollview) {
			this._scrollview.scrollTo({ y: this.props.lastScroll, animated: false })
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		if (this.props.cards !== nextProps.cards ||
			this.props.cardOrder !== nextProps.cardOrder) {
			return true
		} else {
			return false
		}
	}

	handleScroll = (event) => {
		if (this.props.updateScroll) {
			this.props.updateScroll(event.nativeEvent.contentOffset.y)
		}
	}

	_getCards = () => {
		const activeCards = []
		let card

		if (Array.isArray(this.props.cardOrder)) {
			for (let i = 0; i < this.props.cardOrder.length; ++i) {
				const key = this.props.cardOrder[i]

				if (this.props.cards[key].active) {
					switch (key) {
					case 'specialEvents':
						card = <SpecialEventsCardContainer key="specialEvents" />
						break
					case 'weather':
						card = (<WeatherCardContainer key="weather" />)
						break
					case 'shuttle':
						card = (<ShuttleCardContainer key="shuttle" />)
						break
					case 'dining':
						card = (<DiningCardContainer key="dining" />)
						break
					case 'events':
						card = (<EventCardContainer key="events" />)
						break
					case 'quicklinks':
						card = (<QuicklinksCardContainer key="quicklinks" />)
						break
					case 'news':
						card = (<NewsCardContainer key="news" />)
						break
					}
					activeCards.push(card)
				}
			}
		}
		return activeCards
	}

	updateGooglePlay = () => {
		checkGooglePlayServices((result) => {
			if (result === 'update') {
				this.setState({ updatedGoogle: false })
			}
		})
	}

	render() {
		return (
			<ScrollView
				ref={(c) => { this._scrollview = c }}
				onScroll={this.handleScroll}
				scrollEventThrottle={0}
			>
				{/* LOAD CARDS */}
				{ this._getCards() }
			</ScrollView>
		)
	}
}

function mapStateToProps(state, props) {
	return {
		cards: state.cards.cards,
		cardOrder: state.cards.cardOrder,
		lastScroll: state.home.lastScroll,
	}
}

function mapDispatchtoProps(dispatch) {
	return {
		updateScroll: (scrollY) => {
			dispatch({ type: 'UPDATE_HOME_SCROLL', scrollY })
		}
	}
}
export default connect(mapStateToProps, mapDispatchtoProps)(Home)
