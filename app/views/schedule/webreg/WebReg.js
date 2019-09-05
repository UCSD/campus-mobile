import React from 'react'
import { View, Animated, Text } from 'react-native'
import { connect } from 'react-redux'
import { myIndexOf } from '../../../util/schedule'
// import css from '../../../styles/css'

// PAGES
import HomePage from './HomePage'
import CourseSearch from './CourseSearch'

import SearchHeader from './SearchHeader'
import DropDown from './DropDown'
import Filter from './Filter'
import { terms } from './mockData/TermMockData.json'
import { getScreenWidth } from '../../../util/general'

const INITIAL_TERMS = [...terms]
const duration = 5000
const WINDOW_WIDTH = getScreenWidth()

class WebReg extends React.Component {
	static navigationOptions = ({ navigation }) => ({
		headerLeft: null,
		headerRight: null,
		headerTitle: <SearchHeader />
	})

	constructor(props) {
		super()
		this.state = {
			layoutAnim: new Animated.Value(0),
			expanded: false,
		}
		/*
		 0 - HomePage
		 1 - SearchPage
		 */
	}

	componentWillMount() {
		this.props.populateClassArray()
		this.props.selectCourse(null, null)
	}

	componentDidUpdate(prevProps) {
		if (prevProps.filterVisible !== this.props.filterVisible) {
			if (prevProps.filterVisible) {
				this.state.expanded = false
			}
			Animated.timing(
				this.state.layoutAnim,
				{
					toValue: this.props.filterVisible ? 1 : 0,
					duration
				}
			).start()
		}
	}

	handleSelectSwitcher = (choice) => {
		const index = myIndexOf(INITIAL_TERMS, choice)
		choice = INITIAL_TERMS[index]
		this.props.showTermSwitcher(false)
		this.props.selectTerm(choice)
	}

	handleCancelSwitcher = () => {
		this.props.showTermSwitcher(false)
	}

	handleCancelSelector = () => {
		this.props.showTermSelector(false)
	}

	handleSelectSelector = (choice) => {
		const index = myIndexOf(INITIAL_TERMS, choice, 'name')
		choice = INITIAL_TERMS[index]
		this.props.showTermSelector(false)
		this.props.selectTerm(choice)
	}

	constructArr() {
		let selectedTerm
		// Mockdata: added default value to avoid error
		const { selectedTerm: selected } = this.props
		if (selected === null) {
			 selectedTerm = {
				'term_name': 'Spring 2019',
				'term_code': 'SP19'
			}
		}
		if (['term_name', 'term_code'].map(i => selected[i]).some(e => e === null)) {
			selectedTerm = {
				'term_name': 'Spring 2019',
				'term_code': 'SP19'
			}
		} else {
			selectedTerm = selected
		}
		const result = [selectedTerm]
		for (let i = 0; i < INITIAL_TERMS.length; i++) {
			if (INITIAL_TERMS[i].term_code !== selectedTerm.term_code) {
				result.push(INITIAL_TERMS[i])
			}
		}
		return result
	}

	showFilter() {
		if (this.props.filterVisible) {
			if (!this.state.expanded) {
				this.setState({ expanded: true })
			}
			const modalY = new Animated.Value(-133)
			Animated.timing(modalY, {
				duration,
				toValue: 0
			}).start()
			return (
				<Animated.View
					style={{
						position: 'absolute',
						transform: [{ translateY: modalY }],
						width: WINDOW_WIDTH,
					}}
				>
					<Filter />
				</Animated.View>
			)
		} else if (this.state.expanded) {
			const modalY = new Animated.Value(0)
			Animated.timing(modalY, {
				duration,
				toValue: -133
			}).start()
			this.state.expanded = false
			return (
				<Animated.View
					style={{
						position: 'absolute',
						transform: [{ translateY: modalY }],
						width: WINDOW_WIDTH,
					}}
				>
					<Filter />
				</Animated.View>
			)
		}
	}

	showModal() {
		if (this.props.termSwitcherVisible) {
			return (
				<DropDown
					style={{
						left: (this.searchBarX + this.termSwicherX) - 5,
						width: this.termSwicherW,
						top: (this.headerY + 2),
					}}
					onCancel={this.handleCancelSwitcher}
					onSelect={this.handleSelectSwitcher}
					choices={this.constructArr()}
					choiceStyle={styles.dropDownTextStyle}
					containerStyle={styles.dropDownContainerStyle}
				/>
			)
		}
		if (this.props.termSelectorVisible) {
			return (
				<DropDown
					style={{
						left: (this.containerX + this.selectorX + this.parentX) - 0.5,
						top: (this.containerY + this.selectorY + this.parentY) - 10,
						width: this.selectorWidth
					}}
					onCancel={this.handleCancelSelector}
					onSelect={this.handleSelectSelector}
					choices={this.constructArr()}
					isTermName
				/>
			)
		}
	}

	filterData(text) {
		const { data } = this.props.fullScheduleData
		return data.filter(item => ((item.subject_code + item.course_code).toLowerCase()).includes(text.toLowerCase()))
	}

	_renderBody() {
		const filterHeight = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: [0, 133]
		})

		switch (this.props.homeIndex) {
			case 0: return (<HomePage
				initialTerms={INITIAL_TERMS}
				onParent={(event)	=> {
					const { layout } = event.nativeEvent
					this.parentX = layout.x
					this.parentY = layout.y
				}}
				onContainer={(event)	=> {
					const { layout } = event.nativeEvent
					this.containerX = layout.x
					this.containerY = layout.y
				}}
				onSelector={(event)	=> {
					const { layout } = event.nativeEvent
					this.selectorX = layout.x
					this.selectorY = layout.y
					this.selectorWidth = layout.width
				}}
			/>)
			case 1:
				return (
					<View style={{ flex: 1 }}>
						<Animated.View style={{ height: filterHeight }} />
						<CourseSearch />
					</View>
				)
			default: <View />
		}
	}

	render() {
		return (
			<View flex>
				{/* <SearchHeader
					initialTerms={INITIAL_TERMS}
					bodyIndex={this.state.bodyIndex}
				/> */}
				{this._renderBody()}
				{this.showModal()}
				{this.showFilter()}
			</View>
		)
	}
}

const styles = {
	dropDownTextStyle: {
		textAlign: 'left',
		fontSize: 15,
		paddingLeft: 5,
		paddingRight: 5
	},
	dropDownContainerStyle: {
		flex: 1,
		paddingTop: 5,
		paddingBottom: 5,
	}
}

const mapStateToProps = state => ({
	selectedTerm: state.schedule.selectedTerm,
	filterVisible: state.webreg.filterVisible,
	termSwitcherVisible: state.webreg.termSwitcherVisible,
	termSelectorVisible: state.webreg.termSelectorVisible,
	fullScheduleData: state.schedule.data,
	homeIndex: state.webreg.homeIndex,
})


const mapDispatchToProps = (dispatch, ownProps) => (
	{
		selectTerm: (selectedTerm) => {
			dispatch({ type: 'SET_SELECTED_TERM', selectedTerm })
		},
		populateClassArray: () => {
			dispatch({ type: 'POPULATE_CLASS' })
		},
		scheduleLayoutChange: ({ y }) => {
			dispatch({ type: 'SCHEDULE_LAYOUT_CHANGE', y })
		},
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE', selectedCourse, data })
		},
		showTermSwitcher: (termSwitcherVisible) => {
			dispatch({ type: 'CHANGE_TERM_SWITCHER_VISIBILITY', termSwitcherVisible })
		},
		showTermSelector: (termSelectorVisible) => {
			dispatch({ type: 'CHANGE_TERM_SELECTOR_VISIBILITY', termSelectorVisible })
		}
	}
)


export default connect(mapStateToProps, mapDispatchToProps)(WebReg)
