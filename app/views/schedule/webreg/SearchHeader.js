import React from 'react'
import { TouchableOpacity, View, Text, TextInput, Dimensions, StyleSheet } from 'react-native'
import { withNavigation } from 'react-navigation'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'


const { width } = Dimensions.get('window')

class SearchHeader extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			input: '',
			hasText: false,
			isFilterButtonVisible: false,
			isTermSelectorVisible: false,
		}

		this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']

		this.onChangeText = this.onChangeText.bind(this)
		this.onSubmit = this.onSubmit.bind(this)
		this.onFilterPress = this.onFilterPress.bind(this)
		this.onBackButtonPress = this.onBackButtonPress.bind(this)
		this.onClearButtonPress = this.onClearButtonPress.bind(this)
		this.onTermSwitcherPress = this.onTermSwitcherPress.bind(this)
	}

	onChangeText = (text) => {
		this.setState({ input: text })
		if ( text !== '' ) {
			this.setState({ hasText: true })
		} else {
			this.setState({ hasText: false })
		}
	}

	onSubmit() {
		this.setState({ isFilterButtonVisible: true, isTermSelectorVisible: true })
		const { input } = this.state
		this.props.updateInput(input)
		this.props.setBodyToRender(1)
	}

	onFilterPress() {
		this.props.showFilter(true)
	}

	onBackButtonPress() {
		this.props.navigation.goBack()
		this.reset()
	}

	onClearButtonPress() {
		this.props.setBodyToRender(0)
		this.reset()
	}

	onTermSwitcherPress() {
		this.props.showTermSwitcher(true)
	}

	reset() {
		this.setState({
			input: '',
			hasText: false,
			isFilterButtonVisible: false,
			isTermSelectorVisible: false,
		})
		this.props.updateInput('')
		this.props.showFilter(false)
		this.props.showTermSwitcher(false)
	}

	_renderLeftButton() {
		const { leftButtonStyle } = styles

		if (this.state.hasText) {
			return (
				<TouchableOpacity
					style={leftButtonStyle}
					onPress={this.onClearButtonPress}
				>
					<Icon name="close" size={24} />
				</TouchableOpacity>
			)
		}
		return (
			<TouchableOpacity
				style={leftButtonStyle}
				onPress={this.onBackButtonPress}
			>
				<Icon name="navigate-before" size={24} />
			</TouchableOpacity>
		)
	}

	_renderTermSwicher() {
		const { termTextStyle, switcherContainerStyle } = styles
		const { selectedTerm } = this.props

		if (this.state.isTermSelectorVisible) {
			return (
				<TouchableOpacity
					activeOpacity={1}
					onPress={this.onTermSwitcherPress}
					style={switcherContainerStyle}
					onLayout={(event) => { this.props.onLayoutTermSwicher(event) }}
				>
					<Text style={termTextStyle}>{selectedTerm.term_code}</Text>
					<Icon name="unfold-more" size={20} />
				</TouchableOpacity>
			)
		}

		return <View />
	}

	_renderBar() {
		const { input } = this.state
		const { barViewStyle, inputStyle } = styles

		return (
			<View
				style={[barViewStyle]}
				onLayout={(event) => { this.props.onSearchBar(event) }}
			>
				<Icon name="search" size={24} />
				<TextInput
					style={inputStyle}
					value={input}
					placeholder="Search by course code"
					onChangeText={this.onChangeText}
					autoCorrect={false}
					returnKeyType="go"
					onSubmitEditing={this.onSubmit}
				/>
				{this._renderTermSwicher()}
			</View>
		)
	}

	_renderRightButton = () => {
		const { rightButtonStyle } = styles

		if (this.state.isFilterButtonVisible) {
			return (
				<TouchableOpacity
					style={rightButtonStyle}
					onPress={this.onFilterPress}
				>
					<Icon name="filter-list" size={24} />
				</TouchableOpacity>
			)
		}

		return (
			<View
				style={rightButtonStyle}
			>
				<Icon name="lens" color="rgba(0,0,0,0)" size={24} />
			</View>
		)
	}

	render() {
		const { headerContainerStyle } = styles


		return (
			<View
				style={[headerContainerStyle, this.props.style]}
				onLayout={(event) => { this.props.onLayoutHeader(event) }}
			>
				{this._renderLeftButton()}
				{this._renderBar()}
				{this._renderRightButton()}
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
	leftButtonStyle: {
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
	rightButtonStyle: {
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
			dispatch({ type: 'CHANGE_FILTER_VISIBILITY', filterVisible })
		},
		showTermSwitcher: (termSwitcherVisible) => {
			dispatch({ type: 'CHANGE_TERM_SWITCHER_VISIBILITY', termSwitcherVisible })
		}
	}
)

const mapStateToProps = state => ({
	selectedTerm: state.schedule.selectedTerm,
	searchInput: state.webreg.searchInput,
})

export default withNavigation(connect(mapStateToProps, mapDispatchToProps)(SearchHeader))
