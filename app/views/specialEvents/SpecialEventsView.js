import React, { Component } from 'react'
import { View, Text, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import HeaderButtons from 'react-navigation-header-buttons'
import moment from 'moment'
import css from '../../styles/css'
import logger from '../../util/logger'
import SpecialEventsListView from './SpecialEventsListView'
import COLOR from '../../styles/ColorConstants'
import Touchable from '../common/Touchable'

class SpecialEventsView extends Component {
	static navigationOptions = ({ navigation }) => {
		const { params } = navigation.state || {}
		const { title, personal } = params
		return {
			title,
			headerRight: (
				(!personal) ? (
					<HeaderButtons color={COLOR.WHITE}>
						<HeaderButtons.Item
							title="Filter"
							onPress={() => { navigation.navigate('SpecialEventsFilters', { title }) }}
						/>
					</HeaderButtons>
				) : (<View />)
			)
		}
	}

	constructor(props) {
		super(props)
		// Calculate selected day
		let selectedDay
		for (let i = 0; i < props.days.length; ++i) {
			selectedDay = i
			if (moment(props.days[i]).isSameOrAfter(moment(), 'day')) {
				break
			}
		}
		this.state = { selectedDay }
	}

	componentDidMount() {
		logger.trackScreen('View Loaded: SpecialEventsView')
	}

	handleFullPress = () => {
		this.props.navigation.setParams({ personal: false })
	}

	handleMinePress = () => {
		this.props.navigation.setParams({ personal: true })
	}

	handleFilterPress = () => {
		const { title } = this.props.navigation.state.params
		this.props.navigation.navigate('SpecialEventsFilters', { title })
	}

	handleFilterSelect = (labels) => {
		this.props.updateSpecialEventsLabels(labels)
	}

	handleDayPress = (index) => {
		this.setState({ selectedDay: index })
	}

	render() {
		const { personal } = this.props.navigation.state.params
		if (this.props.days) {
			return (
				<View style={[css.main_full, css.flex]}>
					<DaysBar
						days={this.props.days}
						selectedDay={this.state.selectedDay}
						handleDayPress={this.handleDayPress}
					/>
					<SpecialEventsListView
						style={css.sev_specialEventsListView}
						scrollEnabled={true}
						personal={personal}
						selectedDay={this.props.days[this.state.selectedDay]}
						handleFilterPress={this.handleFilterPress}
					/>
					<FakeTabBar
						personal={personal}
						handleFullPress={this.handleFullPress}
						handleMinePress={this.handleMinePress}
					/>
				</View>
			)
		} else {
			return (
				<View style={[css.main_full, css.flex]}>
					<Text style={css.cm_desc}>
						There are no special events available at this time.
						{'\n\n'}Please try again later.
					</Text>
				</View>
			)
		}
	}
}

const FakeTabBar = ({ personal, handleFullPress, handleMinePress }) => (
	<View style={css.sev_tabBar}>
		<View style={css.sev_buttonContainer}>
			<Touchable
				style={personal ? (css.sev_plainButton) : ([css.sev_selectedButton, css.sev_hideLeftBorder])}
				onPress={() => handleFullPress()}
			>
				<Text
					style={personal ? css.sev_plainText : css.sev_selectedText}
					allowFontScaling={false}
				>
					Full Schedule
				</Text>
			</Touchable>
			<Touchable
				style={personal ? css.sev_selectedButton : css.sev_plainButton}
				onPress={() => handleMinePress()}
			>
				<Text
					style={personal ? css.sev_selectedText : css.sev_plainText}
					allowFontScaling={false}
				>
					My Schedule
				</Text>
			</Touchable>
		</View>
	</View>
)

const DaysBar = ({ days, selectedDay, handleDayPress }) => (
	<View style={css.sev_daysBar}>
		<ScrollView
			horizontal
			showsHorizontalScrollIndicator={false}
			style={css.sev_scrollButtonContainer}
			contentContainerStyle={css.sev_scrollContentContainer}
		>
			{
				days.map((day, index) => {
					let tabStyle = null

					if (index === 0) {
						if (index === selectedDay) {
							tabStyle = css.sev_selectedFirstButton
						} else {
							tabStyle = css.sev_plainFirstButton
						}
					} else {
						if (index === selectedDay) {
							tabStyle = css.sev_selectedButton
						} else {
							tabStyle = css.sev_plainButton
						}
					}

					return (
						<Touchable
							key={day}
							style={tabStyle}
							onPress={() => handleDayPress(index)}
						>
							<Text style={index !== selectedDay ? css.sev_plainText : css.sev_selectedDayText}>
								{moment(day).format('MMM D')}
							</Text>
						</Touchable>
					)
				})
			}
		</ScrollView>
	</View>
)

const mapStateToProps = state => ({	days: state.specialEvents.data ? state.specialEvents.data.dates : null })
export default connect(mapStateToProps)(SpecialEventsView)
