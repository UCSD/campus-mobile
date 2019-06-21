import {
	View,
	Text,
	Platform,
	Dimensions,
	Alert,
	TouchableOpacity,
	Animated,
	ScrollView,
	Button
} from 'react-native'
import React from 'react'
import { connect } from 'react-redux'
import { SearchBar } from 'react-native-elements'
import { connect } from 'react-redux'
import Icon from 'react-native-vector-icons/SimpleLineIcons'


import LAYOUT from '../../../styles/LayoutConstants'
import { deviceIphoneX, platformIOS } from '../../../util/general'
import auth from '../../../util/auth'
import css from '../../../styles/css'
import { terms } from './mockData/TermMockData.json'
import DropDown from './DropDown'
import ClassCalendar from './ClassCalendar'
import FinalCalendar from './FinalCalendar'
import ClassCard from './ClassCard'
import ClassList from './ClassList'
import ClassCardBottomSheet from './ClassCardBottomSheet'

const WINDOW_WIDTH = Dimensions.get('window').width
const WINDOW_HEIGHT = Dimensions.get('window').height

var term_arr = [...terms]
const INITIAL_TERMS = [...terms]

class HomePage extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			search: '',
			show: false,
			display_type: 'Calendar',
		}
		this.selectTerm = this.selectTerm.bind(this)
		this.handleCancel = this.handleCancel.bind(this)
		this.handleSelect = this.handleSelect.bind(this)
		this.props.selectTerm({term_name: "Spring 2019", term_code: "SP19"})
	}

	componentWillMount() {
		this.props.selectFinal(null, null)
		this.props.selectFinal(null, null)
	}

	selectTerm() {
		this.setState({ show: true })
	}

	myIndexOf(arr, key, type) {
		for(var i = 0; i < arr.length; i++) {
			if(type === 'name' ? arr[i].term_name === key : arr[i].term_code === key) {
				return i
			}
		}
		return -1
	}

	handleCancel = () => {
		this.setState({ show: false })
	}

	handleSelect = (choice) => {
		term_arr = [...INITIAL_TERMS]
		const index = this.myIndexOf(term_arr, choice, 'name')
		choice = term_arr[index]
		term_arr.unshift(term_arr.splice(index, 1)[0])
		this.setState({ show: false })
		this.props.selectTerm(choice)
	}

	showSelector() {
		if (this.state.show) {
			return (
				<DropDown
					x={this.dropDownX}
					y={this.dropDownY}
					cardWidth={this.width}
					onCancel={this.handleCancel}
					onSelect={this.handleSelect}
					choices={term_arr}
					isTermName
				/>
			)
		}
	}

	renderDisplayType() {
		// 0 - Android, 1 - iPhone, 2 - iPhone X
		let device = 0
		if (platformIOS()) {
			if (deviceIphoneX()) {
				device = 2
			} else {
				device = 1
			}
		}

		if (this.state.display_type === 'Calendar') {
			return <ClassCalendar device={device} />
		} else if (this.state.display_type === 'Finals') {
			return <FinalCalendar device={device} />
		} else {
			return (
				<ScrollView
					style={css.scroll_default}
					contentContainerStyle={css.main_full}
					onMomentumScrollEnd={(e) => {
						console.log(e.nativeEvent.contentOffset.y)
						this.props.scheduleLayoutChange({ y: e.nativeEvent.contentOffset.y })
						// this.props.clearRefresh();
					}}
					onScrollEndDrag={(e) => {
						console.log(e.nativeEvent.contentOffset.y)
						this.props.scheduleLayoutChange({ y: e.nativeEvent.contentOffset.y })
						// this.props.clearRefresh();
					}}
				>
					<Button onPress={() => auth.retrieveAccessToken().then(credentials => console.log(credentials))} title="Get Access Token" />
					<ClassList />
				</ScrollView>
			)
		}
	}

	renderSwitchNavigator(options) {
		const { webreg_homepage_switch_container } = css

		if (platformIOS()) {
			if (deviceIphoneX()) {
				return (
					<View style={[webreg_homepage_switch_container, { paddingBottom: 34 }]}>
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

	renderClassCard() {
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
					bottom: 0,
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<ClassCardBottomSheet data={selectedCourseDetail} props={this.props} />
				</Animated.View>)
		} else if (this.state.lastCourse) {
			const course = this.state.lastCourse
			this.state.lastCourse = null
			const modalY = new Animated.Value(0)
			Animated.timing(modalY, {
				duration: 300,
				toValue: WINDOW_HEIGHT / 4
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: 0,
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<ClassCard data={this.state.lastCourseDetail} props={this.props} />
				</Animated.View>
			)
		}
	}

	renderFinalCard() {
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
					bottom: 0,
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<ClassCardBottomSheet data={selectedCourseFinalDetail} props={this.props} />
				</Animated.View>)
		} else if (this.state.lastFinal) {
			const course = this.state.lastFinal
			this.state.lastFinal = null
			const modalY = new Animated.Value(0)
			Animated.timing(modalY, {
				duration: 300,
				toValue: WINDOW_HEIGHT / 4
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: 0,
					width: WINDOW_WIDTH,
					left: 0,
					right: 0,
					transform: [{ translateY: modalY }]
				}}
				>
					<ClassCard data={this.state.lastFinalDetail} props={this.props} />
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
			webreg_homepage_search_bar,
			webreg_homepage_webreg_homepage_search_bar_container,
			webreg_homepage_search_text
		} = css

		const options = ['Calendar', 'List', 'Finals']

		return (
			<View style={{ backgroundColor: '#FDFDFD', flex: 1 }}>
				<View style={webreg_homepage_term_selector_container}>
					<View style={[webreg_homepage_icon_container_style, { alignItems: 'flex-end', paddingTop: 1 }]}>
						<Icon name="info" onPress={showAppTime} size={18} />
					</View>
					<View
						style={webreg_homepage_term_container}
						onLayout={(event) => {
							const { layout } = event.nativeEvent
							this.width = layout.width + 50
							this.dropDownX = 45
							this.dropDownY = layout.y
						}}
					>
						<Text style={termTextStyle}>{this.props.selectedTerm.term_name}</Text>
					</View>
					<View style={[webreg_homepage_icon_container_style, { alignItems: 'flex-start', paddingTop: 2 }]}>
						<Icon name="arrow-down" onPress={this.selectTerm} size={18} />
					</View>
				</View>
				<View style={webreg_homepage_webreg_homepage_search_bar_container}>
					<View style={webreg_homepage_search_bar}>
						<Icon name="magnifier" size={18} />
						<Text style={webreg_homepage_search_text}> Search Course </Text>
					</View>
				</View>
				{/* <Button onPress={() => auth.retrieveAccessToken().then(credentials => console.log(credentials))} title="Get Access Token" />*/}
				{this.renderDisplayType()}
				{this.renderSwitchNavigator(options)}
				{this.renderClassCard()}
				{this.renderFinalCard()}
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
})

function mapStateToProps(state) {
	return {
		selectedTerm: state.schedule.selectedTerm,
	}
}


const mapDispatchToProps = (dispatch, ownProps) => (
	{
		selectTerm: (selectedTerm) => {
			dispatch({ type: 'SET_SELECTED_TERM', selectedTerm })
		},
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(HomePage)
