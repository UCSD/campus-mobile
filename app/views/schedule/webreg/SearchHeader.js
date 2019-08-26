import React from 'react'
import { TouchableOpacity, View, Text, TextInput, Dimensions, StyleSheet, Keyboard, Animated, TouchableWithoutFeedback } from 'react-native'
import { withNavigation } from 'react-navigation'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import COLOR from '../../../styles/ColorConstants'
import css from '../../../styles/css'


const { width } = Dimensions.get('window')

class SearchHeader extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			input: '',
			// Animation
			layoutAnim: new Animated.Value(0),
		}

		this.filterOptions = ['Lower division', 'Upper division', 'Graduate division']

		this.onFocus = this.onFocus.bind(this)
		this.onSearchIconPress = this.onSearchIconPress.bind(this)
		this.onChangeText = this.onChangeText.bind(this)
		this.onSubmit = this.onSubmit.bind(this)
		this.onFilterPress = this.onFilterPress.bind(this)
		this.onBackButtonPress = this.onBackButtonPress.bind(this)
		this.onCollapseButtonPress = this.onCollapseButtonPress.bind(this)
		this.onTermSwitcherPress = this.onTermSwitcherPress.bind(this)
	}

	onFocus() {
		this.props.selectCourse(null, null)
	}

	onChangeText(text) {
		this.setState({ input: text })
	}

	onSubmit() {
		const { input } = this.state
		if (input) {
			this.props.updateInput(input)
			this.props.setHomeIndex(1)
		}
	}

	onFilterPress() {
		this.props.showFilter(true)
		Keyboard.dismiss()
	}

	onBackButtonPress() {
		this.props.navigation.goBack()
		this.reset()
	}

	onSearchIconPress() {
		Animated.timing(
			this.state.layoutAnim,
			{
				toValue: 1,
				duration: 5000,
			}
		).start()
		this.props.setHomeIndex(1)
		this.input.focus()
	}

	onCollapseButtonPress() {
		Animated.timing(
			this.state.layoutAnim,
			{
				toValue: 0,
				duration: 5000,
			}
		).start()
		this.props.setHomeIndex(0)
		this.reset()
		Keyboard.dismiss()
	}

	onTermSwitcherPress() {
		this.props.showTermSwitcher(true)
		Keyboard.dismiss()
	}

	reset() {
		this.setState({
			input: '',
		})
		this.props.updateInput('')
		this.props.showFilter(false)
		this.props.showTermSwitcher(false)
	}

	_renderTermSwicher() {
		const { termTextStyle, switcherContainerStyle } = styles
		const { selectedTerm } = this.props

		if (this.props.homeIndex) {
			return (
				<TouchableOpacity
					activeOpacity={1}
					onPress={this.onTermSwitcherPress}
					style={switcherContainerStyle}
				>
					<Text style={termTextStyle}>{selectedTerm.term_code}</Text>
					<Icon name="unfold-more" size={20} />
				</TouchableOpacity>
			)
		}

		return <View />
	}

	_renderLeft() {
		const { leftStyle } = styles

		if (this.props.homeIndex === 1) {
			return (
				<TouchableOpacity
					style={leftStyle}
					onPress={this.onCollapseButtonPress}
				>
					<Icon name="navigate-next" color={COLOR.WHITE} size={24} />
				</TouchableOpacity>
			)
		}
		return (
			<TouchableOpacity
				style={leftStyle}
				onPress={this.onBackButtonPress}
			>
				<Icon name="navigate-before" color={COLOR.WHITE} size={24} />
			</TouchableOpacity>
		)
	}

	_renderMid() {
		const { input } = this.state
		const { midStyle, searchBarStyle, inputStyle } = styles

		const midContainerWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['86%', '72%']
		})
		const titleWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['86%', '0%']
		})
		const searchBarWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['14%', '100%']
		})

		return (
			<Animated.View style={{ ...midStyle, width: midContainerWidth }}>
				<Animated.View style={{ width: titleWidth }}>
					<Text style={{ ...css.navTitle, color: COLOR.WHITE, marginTop: 5 }}>
						{' Webreg'}
					</Text>
				</Animated.View>
				<Animated.View
					style={{ ...searchBarStyle, width: searchBarWidth, marginHorizontal: 10 }}
				>
					<TouchableWithoutFeedback onPress={this.onSearchIconPress}>
						<Icon name="search" size={24} />
					</TouchableWithoutFeedback>
					<TextInput
						ref={(ref) => { this.input = ref }}
						style={inputStyle}
						value={input}
						placeholder="Search by course code"
						onChangeText={this.onChangeText}
						autoCorrect={false}
						returnKeyType="go"
						onFocus={this.onFocus}
						onSubmitEditing={this.onSubmit}
					/>
					{/* {this._renderTermSwicher()} */}
				</Animated.View>
			</Animated.View>
		)
	}

	_renderRight = () => {
		const { rightStyle } = styles

		const rightContainerWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['0%', '14%']
		})

		let rightBody = (
			<TouchableOpacity
				onPress={this.onFilterPress}
			>
				<Icon name="filter-list" color={COLOR.WHITE} size={24} />
			</TouchableOpacity>
		)
		if (this.props.homeIndex) {
			rightBody = (
				<TouchableOpacity
					onPress={this.onFilterPress}
				>
					<Icon name="filter-list" color={COLOR.WHITE} size={24} />
				</TouchableOpacity>
			)
		}

		return (
			<Animated.View
				style={{ ...rightStyle, width: rightContainerWidth }}
			>
				{rightBody}
			</Animated.View>
		)
	}

	render() {
		const { headerContainerStyle } = styles

		return (
			<View
				style={[headerContainerStyle, this.props.style]}
			>
				{this._renderLeft()}
				{this._renderMid()}
				{this._renderRight()}
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
		// marginBottom: 15,
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
	leftStyle: {
		width: '14%',
		justifyContent: 'center',
		alignItems: 'center',
	},
	midStyle: {
		// flex: 0.72,
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
	},
	searchBarStyle: {
		// flex: 0.72,
		flexDirection: 'row',
		alignItems: 'center',
		borderWidth: 1,
		borderColor: '#194160',
		borderRadius: 20,
		paddingHorizontal: 5,
		paddingVertical: 3,
		backgroundColor: '#F1F1F1'
	},
	inputStyle: {
		flex: 1,
		fontSize: 15,
		paddingLeft: 5,
		paddingRight: 5
	},
	rightStyle: {
		// flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center',
		// zIndex: 1000,
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
		},
		selectCourse: (selectedCourse, data) => {
			dispatch({ type: 'SELECT_COURSE', selectedCourse, data })
		},
		setHomeIndex: ( homeIndex ) => {
			dispatch({ type: 'SET_HOME_INDEX', homeIndex })
		}
	}
)

const mapStateToProps = state => ({
	selectedTerm: state.schedule.selectedTerm,
	searchInput: state.webreg.searchInput,
	homeIndex: state.webreg.homeIndex,
})

export default withNavigation(connect(mapStateToProps, mapDispatchToProps)(SearchHeader))
