import React, { Component } from 'react'
import {
	View,
	StyleSheet,
	Text,
	ScrollView
} from 'react-native'
import { connect } from 'react-redux'
import HeaderButtons from 'react-navigation-header-buttons'
import moment from 'moment'

import css from '../../styles/css'
import logger from '../../util/logger'
import SpecialEventsListView from './SpecialEventsListView'
import {
	COLOR_SECONDARY,
	COLOR_MGREY,
	COLOR_DGREY,
	COLOR_WHITE,
} from '../../styles/ColorConstants'
import {
	TAB_BAR_HEIGHT,
	WINDOW_WIDTH,
} from '../../styles/LayoutConstants'
import Touchable from '../common/Touchable'

class SpecialEventsView extends Component {
	static navigationOptions = ({ navigation }) => {
		const { params } = navigation.state || {}
		const { title, personal } = params
		return {
			title,
			headerRight: (
				(!personal) ? (
					<HeaderButtons color={COLOR_WHITE}>
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
		logger.ga('View Loaded: SpecialEventsView')
	}

	handleFullPress = () => {
		this.props.navigation.setParams({ personal: false })
	}

	handleMinePress = () => {
		this.props.navigation.setParams({ personal: true })
	}

	handleFilterSelect = (labels) => {
		this.props.updateSpecialEventsLabels(labels)
	}

	handleDayPress = (index) => {
		this.setState({ selectedDay: index })
	}

	render() {
		const { personal } = this.props.navigation.state.params

		return (
			<View style={[css.main_full, css.flex]}>
				<DaysBar
					days={this.props.days}
					selectedDay={this.state.selectedDay}
					handleDayPress={this.handleDayPress}
				/>
				<SpecialEventsListView
					style={styles.specialEventsListView}
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
		);
	}
}

const mapStateToProps = state => ({	days: state.specialEvents.data.dates })
export default connect(mapStateToProps)(SpecialEventsView)

const FakeTabBar = ({ personal, handleFullPress, handleMinePress }) => (
	<View style={styles.tabBar}>
		<View style={styles.buttonContainer}>
			<Touchable
				style={personal ? (styles.plainButton) : ([styles.selectedButton, styles.hideLeftBorder])}
				onPress={() => handleFullPress()}
			>
				<Text
					style={personal ? styles.plainText : styles.selectedText}
					allowFontScaling={false}
				>
					Full Schedule
				</Text>
			</Touchable>
			<Touchable
				style={personal ? styles.selectedButton : styles.plainButton}
				onPress={() => handleMinePress()}
			>
				<Text
					style={personal ? styles.selectedText : styles.plainText}
					allowFontScaling={false}
				>
					My Schedule
				</Text>
			</Touchable>
		</View>
	</View>
)

const DaysBar = ({ days, selectedDay, handleDayPress }) => (
	<View style={styles.daysBar}>
		<ScrollView
			horizontal
			showsHorizontalScrollIndicator={false}
			style={styles.scrollButtonContainer}
			contentContainerStyle={styles.scrollContentContainer}
		>
			{
				days.map((day, index) => {
					let tabStyle = null

					if (index === 0) {
						if (index === selectedDay) {
							tabStyle = styles.selectedFirstButton
						} else {
							tabStyle = styles.plainFirstButton
						}
					} else {
						if (index === selectedDay) {
							tabStyle = styles.selectedButton
						} else {
							tabStyle = styles.plainButton
						}
					}

					return (
						<Touchable
							key={day}
							style={tabStyle}
							onPress={() => handleDayPress(index)}
						>
							<Text
								style={index !== selectedDay ? styles.plainText : styles.selectedDayText}
							>
								{moment(day).format('MMM D')}
							</Text>
						</Touchable>
					)
				})
			}
		</ScrollView>
	</View>
)

const styles = StyleSheet.create({
	specialEventsListView: { flex: 1 },
	scrollButtonContainer: { flexDirection: 'row' },
	scrollContentContainer: { flexGrow: 1 },
	buttonContainer: { flex: 1, flexDirection: 'row', alignItems: 'center' },
	selectedButton: { flexGrow: 1, minWidth: Math.round(WINDOW_WIDTH / 3.65), height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_SECONDARY, borderLeftWidth: 1, borderLeftColor: COLOR_MGREY },
	selectedFirstButton: { flexGrow: 1, minWidth: WINDOW_WIDTH / 4, height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_SECONDARY },
	plainButton: { flexGrow: 1, minWidth: Math.round(WINDOW_WIDTH / 3.65), height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_WHITE, borderLeftWidth: 1, borderLeftColor: COLOR_MGREY },
	plainFirstButton: { flexGrow: 1, minWidth: Math.round(WINDOW_WIDTH / 3.65), height: TAB_BAR_HEIGHT, alignItems: 'center', justifyContent: 'center', backgroundColor: COLOR_WHITE },
	hideLeftBorder: { borderLeftWidth: 0 },
	selectedText: { textAlign: 'center', fontSize: 18, color: 'white' },
	plainText: { textAlign: 'center', fontSize: 18, opacity: 0.5 },
	tabBar: { borderTopWidth: 1, borderColor: COLOR_DGREY, backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
	daysBar: { borderBottomWidth: 1, borderColor: COLOR_MGREY, backgroundColor: COLOR_WHITE, height: TAB_BAR_HEIGHT },
	selectedDayText: { textAlign: 'center', fontSize: 18, color: COLOR_WHITE, backgroundColor: COLOR_SECONDARY },
	filterText: { textAlign: 'center', fontSize: 17, color: 'white' },
	backButtonContainer: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', marginTop: -7 },
	backButtonImage: { color: COLOR_WHITE, marginRight: 7 },
})
