import React from 'react'
import { TouchableOpacity, View, Text, TextInput, Image, Switch } from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'
import { withNavigation } from 'react-navigation'
import { connect } from 'react-redux'
import NavigationService from '../../../navigation/NavigationService'
import ResultList from './ResultList'
import SearchHeader from './SearchHeader'
import DropDown from './DropDown'
import Filter from './Filter'
import { myIndexOf } from '../../../util/schedule'


class CourseSearchList extends React.Component {
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
		const { initialTerms } = this.props
		const index = myIndexOf(initialTerms, choice)
		choice = initialTerms[index]
		this.setState({ showTermSwitcher: false })
		this.props.selectTerm(choice)
	}

	handleCancel = () => {
		this.setState({ showTermSwitcher: false })
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

	render() {
		const { onGoBack, initialTerms } = this.props
		return (
			<View flex style={{ backgroundColor: 'white' }}>
				<SearchHeader
					getDropDownLayout={this.getDropDownLayout}
					initialTerms={initialTerms}
					onSelectTerm={() => this.setState({ showTermSwitcher: true })}
					onPress={onGoBack}
				/>
				<ResultList />
				{this.props.showFilter && <Filter />}
				{this.showSelector()}
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
	showFilter: state.course.filterVisible,
	selectedTerm: state.schedule.selectedTerm,
})

const mapDispatchToProps = dispatch => (
	{
		selectTerm: (selectedTerm) => {
			dispatch({ type: 'SET_SELECTED_TERM', selectedTerm })
		},
	}
)


export default withNavigation( connect(mapStateToProps, mapDispatchToProps)(CourseSearchList))
