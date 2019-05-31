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
import { SearchBar } from 'react-native-elements'
import { connect } from 'react-redux'
import Icon from 'react-native-vector-icons/SimpleLineIcons'

import { terms } from './TermMockData.json'
import DropDown from './DropDown'
import LAYOUT from '../../../styles/LayoutConstants'
import css from '../../../styles/css'
import auth from '../../../util/auth'
import { deviceIphoneX, platformIOS } from '../../../util/general'
import ClassCalendar from './ClassCalendar'
import ClassCard from './ClassCard'
import ClassList from './ClassList'
import ClassCardBottomSheet from './ClassCardBottomSheet'
import FinalCalendar from './FinalCalendar'

const WINDOW_WIDTH = Dimensions.get('window').width
const WINDOW_HEIGHT = Dimensions.get('window').height


const { width, height } = Dimensions.get('window')

let termNameArr = []
let termCodeArr = []

const INITIAL_NAME_ARR = []
const INITIAL_CODE_ARR = []

terms.forEach((element) => {
	termNameArr.push(element.term_name)
	termCodeArr.push(element.term_code)
	INITIAL_NAME_ARR.push(element.term_name)
	INITIAL_CODE_ARR.push(element.term_code)
})

class HomePage extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			search: '',
			term: 'Spring 2019',
			show: false,
			display_type: 'Calendar',
			lastCourse: null
		}
		this.showAppTime = this.showAppTime.bind(this)
		this.selectTerm = this.selectTerm.bind(this)
		this.handleCancel = this.handleCancel.bind(this)
		this.handleSelect = this.handleSelect.bind(this)
	}

	// componentDidMount() {
	//   updatePosition(this.refs['TERM_SELECT']);
	// }
	//
	// _term(newTerm) {
	// this.setState({
	//     ...this.state,
	//     term: newTerm
	//   });
	// }

	updateSearch = (search) => {
		this.setState({ search })
	};

	showAppTime = () => {
		Alert.alert(
			'Your Appointment Time',
			'First Pass: \n Second Pass:',
			[
				{ text: 'OK', onPress: () => console.log('OK Pressed') },
			],
			{ cancelable: false },
		)
	}

	selectTerm() {
		this.setState({ show: true })
	}

	handleCancel = () => {
		this.setState({ show: false })
	}

	handleSelect = (choice) => {
		termNameArr = [...INITIAL_NAME_ARR]
		termCodeArr = [...INITIAL_CODE_ARR]
		const index = termNameArr.indexOf(choice)
		termNameArr.unshift(termNameArr.splice(index, 1))
		termCodeArr.unshift(termCodeArr.splice(index, 1))
		this.setState({ show: false, term: choice })
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
					choices={termNameArr}
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
		const { switchContainerStyle } = styles

		if (platformIOS()) {
			if (deviceIphoneX()) {
				return (
					<View style={[switchContainerStyle, { paddingBottom: 34 }]}>
						{options.map((opt, i) => this.renderButton(opt, i))}
					</View>
				)
			} else {
				return (
					<View style={switchContainerStyle}>
						{options.map((opt, i) => this.renderButton(opt, i))}
					</View>
				)
			}
		}
	}

	renderButton(value, index) {
		const { switchItemStyle, switchTextStyle, chosenItemStyle } = styles

		if (value === this.state.display_type) {
			return (
				<View style={switchItemStyle} key={index}>
					<TouchableOpacity disabled style={chosenItemStyle}>
						<Text style={[switchTextStyle, { color: '#034263' }]}>{value}</Text>
					</TouchableOpacity>
				</View>
			)
		}

		return (
			<View style={switchItemStyle} key={index}>
				<TouchableOpacity onPress={() => this.setState({ display_type: value })}>
					<Text style={switchTextStyle}>{value}</Text>
				</TouchableOpacity>
			</View>
		)
	}

	renderClassCard() {
		const { selectedCourse, selectedCourseDetail } = this.props
		if (selectedCourse) {
			this.state.lastCourse = selectedCourse
			this.state.lastCourseDetail = selectedCourseDetail
			const modalY = new Animated.Value(height / 4)
			Animated.timing(modalY, {
				duration: 300,
				toValue: 0
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: 0,
					width,
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
				toValue: height / 4
			}).start()
			return (
				<Animated.View style={{
					position: 'absolute',
					bottom: 0,
					width,
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

	render() {
		const {
			termContainerStyle,
			termTextStyle,
			termSelectorContainerStyle,
			iconContainerStyle
		} = styles

		const options = ['Calendar', 'List', 'Finals']

		return (
			<View style={{ backgroundColor: '#F5F5F5', flex: 1 }}>
				<View style={termSelectorContainerStyle}>
					<View style={[iconContainerStyle, { alignItems: 'flex-end', paddingTop: 1 }]}>
						<Icon name="info" onPress={this.showAppTime} size={18} />
					</View>
					<View
						style={termContainerStyle}
						onLayout={(event) => {
							const { layout } = event.nativeEvent
							this.width = layout.width + 50
							this.dropDownX = 45
							this.dropDownY = layout.y
						}}
					>
						<Text style={termTextStyle}>{this.state.term}</Text>
					</View>
					<View style={[iconContainerStyle, { alignItems: 'flex-start', paddingTop: 2 }]}>
						<Icon name="arrow-down" onPress={this.selectTerm} size={18} />
					</View>
				</View>
				<View style={{ marginLeft: 15, marginRight: 15 }}>
					<SearchBar ref={search => this.search = search} placeholder="Search Course" onChangeText={this.updateSearch} value={this.state.search} platform={Platform.OS} onCancel={() => console.log('hahaa')} autoCorrect={false} />
				</View>
				{this.renderDisplayType()}
				{this.renderSwitchNavigator(options)}
				{this.renderClassCard()}
				{this.showSelector()}

			</View>
		)
	}
}

const styles = {
	termContainerStyle: {
		flex: 1,
	},
	termTextStyle: {
		fontFamily: 'Helvetica Neue',
		fontSize: 18,
		alignSelf: 'center'
	},
	termSelectorContainerStyle: {
		flexDirection: 'row',
		marginTop: 20,
		marginBottom: 10,
		marginLeft: 50,
		marginRight: 50
	},
	iconContainerStyle: {
		justifyContent: 'center',
		width: 20,
		height: 20
	},
	switchContainerStyle: {
		paddingTop: 17,
		paddingBottom: 17,
		bottom: 0,
		position: 'absolute',
		flexDirection: 'row',
		backgroundColor: '#F5F5F5',
		flex: 1
	},
	switchItemStyle: {
		flex: 1 / 3,
		justifyContent: 'center',
		alignItems: 'center'
	},
	switchTextStyle: {
		color: '#7D7D7D',
		paddingTop: 1,
		paddingBottom: 1
	},
	chosenItemStyle: {
		 borderColor: '#034263',
		 borderBottomWidth: 1
	}
}

function mapStateToProps(state) {
	return {
		selectedCourse: state.schedule.selectedCourse,
		selectedCourseDetail: state.schedule.selectedCourseDetail,
		fullScheduleData: state.schedule.data,
	}
}


const mapDispatchToProps = (dispatch, ownProps) => (
	{
		populateClassArray: () => {
			dispatch({ type: 'POPULATE_CLASS' })
		},
		scheduleLayoutChange: ({ y }) => {
			dispatch({ type: 'SCHEDULE_LAYOUT_CHANGE', y })
		}
	}
)

export default connect(mapStateToProps, mapDispatchToProps)(HomePage)
