import React from 'react'
import { StatusBar } from 'react-native'
import { withNavigation, SafeAreaView } from 'react-navigation'
import { connect } from 'react-redux'
import ResultList from './ResultList'
import SearchHeader from './SearchHeader'
import DropDown from './DropDown'
import Filter from './Filter'
import { myIndexOf } from '../../../util/schedule'
import { terms } from './mockData/TermMockData.json'
import { deviceIphoneX } from '../../../util/general'

const INITIAL_TERMS = [...terms]

class CourseSearch extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			showTermSwitcher: false,
		}

		this.getDropDownLayout = this.getDropDownLayout.bind(this)
	}


	getDropDownLayout = (x, y, width) => {
		this.dropDownX = x
		this.dropDownY = y
		this.width = width
	}

	handleSelect = (choice) => {
		const index = myIndexOf(INITIAL_TERMS, choice)
		choice = INITIAL_TERMS[index]
		this.setState({ showTermSwitcher: false })
		this.props.selectTerm(choice)
	}

	handleCancel = () => {
		this.setState({ showTermSwitcher: false })
	}

	constructArr() {
		const { selectedTerm } = this.props
		const result = [selectedTerm]
		for (let i = 0; i < INITIAL_TERMS.length; i++) {
			if (INITIAL_TERMS[i].term_code !== selectedTerm.term_code) {
				result.push(INITIAL_TERMS[i])
			}
		}
		return result
	}

	showSelector() {
		if (this.state.showTermSwitcher) {
			return (
				<DropDown
					x={this.dropDownX}
					y={this.dropDownY}
					cardWidth={this.width}
					onCancel={this.handleCancel}
					onSelect={this.handleSelect}
					choices={this.constructArr()}
					choiceStyle={styles.dropDownTextStyle}
					containerStyle={styles.dropDownContainerStyle}
				/>
			)
		}
	}

	componentDidMount = () => {
		this.props.updateInput('')
		this.props.updateFilterStatus(false)
		this.props.updateFilterVal([false, false, false])
	}

	render() {
		return (
			<SafeAreaView flex style={{ backgroundColor: 'white' }}>
				<StatusBar
					barStyle="dark-content"
				// backgroundColor={COLOR.PRIMARY}
				/>
				<SearchHeader
					getDropDownLayout={this.getDropDownLayout}
					initialTerms={INITIAL_TERMS}
					onSelectTerm={() => this.setState({ showTermSwitcher: true })}
				/>
				<ResultList />
				{this.props.showFilter && <Filter style={{
					position: 'absolute',
					top: deviceIphoneX() ? 76 : 55,
					right: 0,
				}} />}
				{this.showSelector()}
			</SafeAreaView>
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
	showFilter: state.course.filterVisible,
	selectedTerm: state.schedule.selectedTerm,
})

const mapDispatchToProps = dispatch => (
	{
		selectTerm: (selectedTerm) => {
			dispatch({ type: 'SET_SELECTED_TERM', selectedTerm })
		},
		updateFilterVal: (filterVal) => {
			dispatch({
				type: 'UPDATE_FILTER',
				filterVal
			})
		},
		updateFilterStatus: (filterVisible) => {
			dispatch({ type: 'CHANGE_FILTER_STATUS', filterVisible })
		},
		updateInput: (searchInput) => {
			dispatch({ type: 'UPDATE_SEARCH_INPUT', searchInput })
		},
	}
)


export default withNavigation(connect(mapStateToProps, mapDispatchToProps)(CourseSearch))
