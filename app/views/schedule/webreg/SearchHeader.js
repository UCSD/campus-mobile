import React from 'react'
import { TouchableOpacity, View, Text, TextInput, Dimensions, StyleSheet } from 'react-native'
import { withNavigation } from 'react-navigation'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import { deviceIphoneX } from '../../../util/general'


const { width } = Dimensions.get('window')

class SearchHeader extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			input: '',
		}

		this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']

		this.onChangeText = this.onChangeText.bind(this)
		this.onSubmit = this.onSubmit.bind(this)
		this.onFilterPress = this.onFilterPress.bind(this)
		this.onBackButtonPress = this.onBackButtonPress.bind(this)
	}

	onChangeText = (text) => {
		this.setState({ input: text })
	}

	onSubmit = () => {
		const { input } = this.state
		this.props.updateInput(input)
	}

	onFilterPress = () => {
		this.props.showFilter(true)
	}

	onBackButtonPress = () => {
		this.props.navigation.goBack()
		this.props.updateInput('')
		this.props.showFilter(false)
	}

	renderBackButton() {
		const { backBtnStyle } = styles

		return (
			<TouchableOpacity
				style={backBtnStyle}
				onPress={this.onBackButtonPress}
			>
				<Icon name="navigate-before" size={24} />
			</TouchableOpacity>
		)
	}

	renderBar = () => {
		const { input } = this.state
		const { barViewStyle, inputStyle, termTextStyle, switcherContainerStyle } = styles
		const { selectedTerm, getDropDownLayout, onSelectTerm } = this.props

		return (
			<View style={[barViewStyle]}>
				<Icon name="search" size={24} />
				<TextInput
					style={inputStyle}
					value={input}
					onChangeText={this.onChangeText}
					autoCorrect={false}
					autoFocus={true}
					returnKeyType="go"
					onSubmitEditing={this.onSubmit}
				/>
				<TouchableOpacity
					activeOpacity={1}
					onPress={onSelectTerm}
					style={switcherContainerStyle}
					onLayout={(event) => {
						const { layout } = event.nativeEvent
						getDropDownLayout(45, layout.y + (deviceIphoneX() ? 30 : 6), layout.width + 20)
					}}
				>
					<Text style={termTextStyle}>{selectedTerm.term_code}</Text>
					<Icon name="unfold-more" size={20} />
				</TouchableOpacity>
			</View>
		)
	}

	renderFilterButton = () => {
		const { filterBtnStyle } = styles

		return (
			<TouchableOpacity
				style={filterBtnStyle}
				onPress={this.onFilterPress}
			>
				<Icon name="filter-list" size={24} />
			</TouchableOpacity>
		)
	}

	render() {
		const { headerContainerStyle } = styles


		return (
			<View
				style={[headerContainerStyle, this.props.style]}
			>
				{this.renderBackButton()}
				{this.renderBar()}
				{this.renderFilterButton()}
			</View>
		)
	}
}

const styles = StyleSheet.create({
	switcherContainerStyle: {
		alignItems: 'center',
		flexDirection: 'row'
	},
	headerContainerStyle: {
		flexDirection: 'row',
		width: '100%',
		// marginTop: 15,
		marginBottom: 15,
		justifyContent: 'center',
		alignItems: 'center',
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 1,
		},
		shadowOpacity: 0.1,
		shadowRadius: 2,
	},
	termTextStyle: {
		color: '#7D7D7D',
		fontSize: 15
	},
	backBtnStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center'
	},
	barViewStyle: {
		flex: 0.72,
		flexDirection: 'row',
		alignItems: 'center',
		borderWidth: 1,
		borderColor: '#194160',
		borderRadius: 20,
		paddingHorizontal: 10,
		paddingVertical: 3,
		backgroundColor: '#F1F1F1'
	},
	inputStyle: {
		flex: 1,
		fontSize: 15,
		paddingLeft: 10,
		paddingRight: 10
	},
	filterBtnStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center',
		zIndex: 1000,
	},
	lineSeparator: {
		borderWidth: 0.5,
		width: (width / 2) - 20,
		height: 0.5,
		marginVertical: 13,
		borderColor: 'rgba(0, 0, 0, 0.1)'
	},
	overlayStyle: {
		flex: 1,
		position: 'absolute',
		backgroundColor: 'black',
		opacity: 0.2,
	}
})

const mapDispatchToProps = dispatch => (
	{
		updateInput: (searchInput) => {
			dispatch({ type: 'UPDATE_SEARCH_INPUT', searchInput })
		},
		selectTerm: (selectedTerm) => {
			dispatch({ type: 'SET_SELECTED_TERM', selectedTerm })
		},
		showFilter: (filterVisible) => {
			dispatch({ type: 'CHANGE_FILTER_STATUS', filterVisible })
		}
	}
)

const mapStateToProps = state => ({
	selectedTerm: state.schedule.selectedTerm,
	searchInput: state.course.searchInput,
	filterVisible: state.course.filterVisible
})

export default withNavigation(connect(mapStateToProps, mapDispatchToProps)(SearchHeader))
