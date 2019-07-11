import {
	View,
	Text,
	Dimensions,
	Alert,
	TouchableOpacity,
	Animated,
	Button,
} from 'react-native'
import React from 'react'
import { connect } from 'react-redux'
import Icon from 'react-native-vector-icons/MaterialIcons'
import NavigationService from '../../../navigation/NavigationService'

import { deviceIphoneX, platformIOS, getScreenWidth, getScreenHeight } from '../../../util/general'
import { getBottomMargin, myIndexOf } from '../../../util/schedule'
import auth from '../../../util/auth'
import css from '../../../styles/css'
import DropDown from './DropDown'
import ClassCalendar from './ClassCalendar'
import FinalCalendar from './FinalCalendar'
import CourseList from './CourseList'
import CalendarModalCard from './CalendarModalCard'

const WINDOW_WIDTH = getScreenWidth()
const WINDOW_HEIGHT = getScreenHeight()

const showAppTime = () => {
	Alert.alert(
		'Your Appointment Time',
		'First Pass: Wed, 05/15 8:20 am - Fri, 05/17 11:59 \n Second Pass: Mon, 05/27 8:00 am - Thurs, 08/22 11:59 pm',
		[
			{ text: 'OK', onPress: () => console.log('OK Pressed') },
		],
		{ cancelable: false },
	)
}


const getDeviceType = () => {
	/*
	 * 0 - Android,
	 * 1 - iPhone,
	 * 2 - iPhone X
	 */
	if (platformIOS()) {
		if (deviceIphoneX()) {
			return 2
		} else {
			return 1
		}
	}
	return 0
}

class HomePage extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			show: false,
			display_type: 'Calendar'
		}
		this.selectTerm = this.selectTerm.bind(this)
		this.handleCancel = this.handleCancel.bind(this)
		this.handleSelect = this.handleSelect.bind(this)
	}

	componentWillMount() {
		this.props.selectFinal(null, null)
	}

	selectTerm() {
		this.setState({ show: true })
	}

	_onSearchBarPressed = () => {
		NavigationService.navigate('CourseSearch')
	}

	constructArr() {
		const { initialTerms, selectedTerm } = this.props
		const result = [selectedTerm]
		for (let i = 0; i < initialTerms.length; i++) {
			if (initialTerms[i].term_code !== selectedTerm.term_code) {
				result.push(initialTerms[i])
			}
		}
		return result
	}

	handleCancel = () => {
		this.setState({ show: false })
	}

	handleSelect = (choice) => {
		const { initialTerms } = this.props
		const index = myIndexOf(initialTerms, choice, 'name')
		choice = initialTerms[index]
		this.setState({ show: false })
		this.props.selectTerm(choice)
	}

	showSelector() {
		if (this.state.show) {
			return (
				<DropDown
					style={{
						left: this.dropDownX,
						top: this.dropDownY,
						width: this.dropDownWidth
					}}
					onCancel={this.handleCancel}
					onSelect={this.handleSelect}
					choices={this.constructArr()}
					isTermName
				/>
			)
		}
	}

	renderDisplayType() {
		const device = getDeviceType()

		if (this.state.display_type === 'Calendar') {
			return (
				<View style={{ flex: 1 }}>
					<Button onPress={() => auth.retrieveAccessToken().then(credentials => console.log(credentials))} title="Get Access Token" />
					<ClassCalendar device={device} />
				</View>
			)
		} else if (this.state.display_type === 'Finals') {
			return <FinalCalendar device={device} />
		} else {
			return <CourseList device={device} />
		}
	}

	renderSwitchNavigator(options) {
		const { webreg_homepage_switch_container } = css

		if (platformIOS()) {
			if (deviceIphoneX()) {
				return (
					<View style={webreg_homepage_switch_container}>
						{options.map((opt, i) => this.renderButton(opt, i))}
					</View>
				)
			} else {
				return (
					<View style={webreg_homepage_switch_container}>
						{options.map((opt, i) => this.renderButton(opt, i))}
					</View>
				)
			}
		}
	}

	renderButton(value, index) {
		const { webreg_homepage_switch_item, webreg_homepage_switch_text, webreg_homepage_chosen_item } = css

		if (value === this.state.display_type) {
			return (
				<View style={webreg_homepage_switch_item} key={index}>
					<TouchableOpacity disabled style={webreg_homepage_chosen_item}>
						<Text style={[webreg_homepage_switch_text, { color: '#034263' }]}>{value}</Text>
					</TouchableOpacity>
				</View>
			)
		}

		return (
			<View style={webreg_homepage_switch_item} key={index}>
				<TouchableOpacity onPress={() => this.setState({ display_type: value })}>
					<Text style={webreg_homepage_switch_text}>{value}</Text>
				</TouchableOpacity>
			</View>
		)
	}

	renderModalCard() {
		const { selectedCourse, selectedCourseDetail } = this.props
		if (selectedCourse) {
			this.state.lastCourse = selectedCourse
			this.state.lastCourseDetail = selectedCourseDetail
			const modalY = new Animated.Value(WINDOW_HEIGHT / 4)
			Animated.timing(modalY, {
				duration: 300,
				toValue: 0
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: getBottomMargin(getDeviceType(), 'card'),
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<CalendarModalCard data={selectedCourseDetail} props={this.props} />
				</Animated.View>)
		} else if (this.state.lastCourse) {
			this.state.lastCourse = null
			const modalY = new Animated.Value(0)
			Animated.timing(modalY, {
				duration: 300,
				toValue: WINDOW_HEIGHT / 4
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: -42,
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<CalendarModalCard data={this.state.lastCourseDetail} props={this.props} />
				</Animated.View>
			)
		}
	}

	renderFinalModalCard() {
		const { selectedCourseFinal, selectedCourseFinalDetail } = this.props
		if (selectedCourseFinal) {
			this.state.lastFinal = selectedCourseFinal
			this.state.lastFinalDetail = selectedCourseFinalDetail
			const modalY = new Animated.Value(WINDOW_HEIGHT / 4)
			Animated.timing(modalY, {
				duration: 300,
				toValue: 0
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: getBottomMargin(getDeviceType(), 'card'),
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<CalendarModalCard data={selectedCourseFinalDetail} props={this.props} />
				</Animated.View>)
		} else if (this.state.lastFinal) {
			this.state.lastFinal = null
			const modalY = new Animated.Value(0)
			Animated.timing(modalY, {
				duration: 300,
				toValue: WINDOW_HEIGHT / 4
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: -28,
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<CalendarModalCard data={this.state.lastFinalDetail} props={this.props} />
				</Animated.View>
			)
		}
	}

	render() {
		const {
			webreg_homepage_term_container,
			webreg_homepage_term_text,
			webreg_homepage_term_selector_container,
			webreg_homepage_icon_container_style,
		} = css

		const options = ['Calendar', 'List', 'Finals']

		return (
			<View style={{ backgroundColor: '#FDFDFD', flex: 1 }}>
				<View
					style={webreg_homepage_term_selector_container}
					onLayout={(event) => {
						const { layout } = event.nativeEvent
						this.containerX = layout.x
						this.containerY = layout.y
					}}
				>
					<View style={webreg_homepage_icon_container_style}>
						<Icon name="alarm" onPress={showAppTime} size={24} />
					</View>
					<View
						style={webreg_homepage_term_container}
						onLayout={(event) => {
							const { layout } = event.nativeEvent
							this.dropDownWidth = layout.width
							this.dropDownX = layout.x + this.containerX
							this.dropDownY = layout.y + this.containerY
						}}
					>
						<Text style={webreg_homepage_term_text}>{this.props.selectedTerm.term_name}</Text>
					</View>
					<View style={webreg_homepage_icon_container_style}>
						<Icon name="arrow-drop-down" onPress={this.selectTerm} size={24} />
					</View>
				</View>
				{this.renderDisplayType()}
				{this.renderSwitchNavigator(options)}
				{this.renderModalCard()}
				{this.renderFinalModalCard()}
				{this.showSelector()}
			</View>
		)
	}
}


const mapStateToProps = state => ({
	selectedCourse: state.schedule.selectedCourse,
	selectedCourseDetail: state.schedule.selectedCourseDetail,
	selectedCourseFinal: state.schedule.selectedCourseFinal,
	selectedCourseFinalDetail: state.schedule.selectedCourseFinalDetail,
	fullScheduleData: state.schedule.data,
	selectedTerm: state.schedule.selectedTerm,
})


const mapDispatchToProps = (dispatch, ownProps) => (
	{
		populateClassArray: () => {
			dispatch({ type: 'POPULATE_CLASS' })
		},
		scheduleLayoutChange: ({ y }) => {
			dispatch({ type: 'SCHEDULE_LAYOUT_CHANGE', y })
		},
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE', selectedCourse, data })
		},
		selectFinal: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE_FINAL', selectedCourse, data })
		},
		selectTerm: (selectedTerm) => {
			dispatch({ type: 'SET_SELECTED_TERM', selectedTerm })
		},
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(HomePage)
