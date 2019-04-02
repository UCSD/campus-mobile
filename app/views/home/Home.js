import React from 'react'
import { View, Text, ScrollView, Alert } from 'react-native'
import { connect } from 'react-redux'
import { checkGooglePlayServices } from 'react-native-google-api-availability-bridge'
import Barcode from 'react-native-barcode-builder'
import Modal from 'react-native-modal'

import WeatherCardContainer from '../weather/WeatherCardContainer'
import ShuttleCardContainer from '../shuttle/ShuttleCardContainer'
import EventCardContainer from '../events/EventCardContainer'
import QuicklinksCardContainer from '../quicklinks/QuicklinksCardContainer'
import NewsCardContainer from '../news/NewsCardContainer'
import DiningCardContainer from '../dining/DiningCardContainer'
import SpecialEventsCardContainer from '../specialEvents/SpecialEventsCardContainer'
import StudentIDCardContainer from '../studentId/StudentIDCardContainer'
import FinalsCard from '../schedule/FinalsCard'
import ScheduleCardContainer from '../schedule/ScheduleCardContainer'
import ParkingCardContainer from '../parking/ParkingCardContainer'
import Touchable from '../common/Touchable'
import { platformAndroid, gracefulFatalReset } from '../../util/general'
import logger from '../../util/logger'
import css from '../../styles/css'
import COLOR from '../../styles/ColorConstants'

export class Home extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			updatedGoogle: true, // eslint-disable-line
			isModalVisible: false
		}
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
			this.props.cardOrder !== nextProps.cardOrder ||
			this.props.user.isLoggedIn !== nextProps.user.isLoggedIn ||
			this.state.isModalVisible !== nextState.isModalVisible) {
			return true
		} else {
			return false
		}
	}

	componentDidUpdate(prevProps) {
		if (!prevProps.user.invalidSavedCredentials &&
			this.props.user.invalidSavedCredentials) {
			Alert.alert(
				'Logged Out.',
				'You have been logged out because your credentials could not be verified. Please try to log in again.',
				[
					{
						text: 'Cancel',
						style: 'cancel'
					},
					{
						text: 'Log in',
						onPress: () => {
							this.props.navigation.navigate('LoginScreen')
						}
					}
				]
			)
		}
	}

	handleScroll = (event) => {
		if (this.props.updateScroll) {
			this.props.updateScroll(event.nativeEvent.contentOffset.y)
		}
	}

	_toggleModal = () => {
		this.setState({ isModalVisible: !this.state.isModalVisible })
	}

	_getCards = () => {
		const activeCards = []

		if (Array.isArray(this.props.cardOrder)) {
			this.props.cardOrder.forEach((card) => {
				if (this.props.cards[card].active) {
					// Skip cards if they require authentication
					// and user is not authenticated
					if (this.props.cards[card].authenticated) {
						if (!this.props.user.isLoggedIn) {
							return
						} else if (this.props.cards[card].classifications &&
                                   this.props.cards[card].classifications.student &&
                                   !this.props.user.profile.classifications.student) {
							return
						}
					}

					switch (card) {
						case 'specialEvents':
							activeCards.push(<SpecialEventsCardContainer key="specialEvents" />)
							break
						case 'studentId':
							activeCards.push(<StudentIDCardContainer key="studentId" />)
							break
						case 'finals':
							activeCards.push(<FinalsCard key="finals" />)
							break
						case 'schedule':
							activeCards.push(<ScheduleCardContainer key="schedule" />)
							break
						case 'weather':
							activeCards.push(<WeatherCardContainer key="weather" />)
							break
						case 'shuttle':
							activeCards.push(<ShuttleCardContainer key="shuttle" />)
							break
						case 'dining':
							activeCards.push(<DiningCardContainer key="dining" />)
							break
						case 'events':
							activeCards.push(<EventCardContainer key="events" />)
							break
						case 'quicklinks':
							activeCards.push(<QuicklinksCardContainer key="quicklinks" />)
							break
						case 'news':
							activeCards.push(<NewsCardContainer key="news" />)
							break
						case 'parking':
							activeCards.push(<ParkingCardContainer key="parking" />)
							break
						default:
							return gracefulFatalReset(new Error('Invalid card in state: ', card))
					}
				}
			})
		}
		return activeCards
	}

	updateGooglePlay = () => {
		checkGooglePlayServices((result) => {
			if (result === 'update') {
				this.setState({ updatedGoogle: false }) // eslint-disable-line
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

				<View style={[css.card_main, css.card_demo]}>
					<Touchable onPress={this._toggleModal}>
						<View style={{ transform: [{ scaleX: 0.75 }] }}>
							<Barcode
								format="codabar"
								value="1234567890"
								width={2}
								height={40}
							/>
						</View>
					</Touchable>

					<Modal
						style={{ margin: 0, backgroundColor: COLOR.WHITE }}
						isVisible={this.state.isModalVisible}
					>
						<View style={{ position: 'absolute', bottom: 32, right: 16, transform: [{ rotate: '90deg' }], fontSize: 16 }}>
							<Touchable onPress={() => this.setState({ isModalVisible: false })}>
								<Text style={{ textAlign: 'right', padding: 8, color: COLOR.PRIMARY }}>Close</Text>
							</Touchable>
						</View>

						<View style={{ transform: [{ rotate: '90deg' }] }}>
							<Barcode
								format="codabar"
								value="1234567890"
								height={100}
								width={4}
							/>
						</View>
					</Modal>
				</View>

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
		user: state.user
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
