import React from 'react'
import { TouchableOpacity, View, Text, TextInput, Dimensions, StyleSheet, Keyboard, Animated, TouchableWithoutFeedback } from 'react-native'
import { withNavigation } from 'react-navigation'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { connect } from 'react-redux'
import COLOR from '../../../styles/ColorConstants'
import css from '../../../styles/css'


const { width } = Dimensions.get('window')
const duration = 5000
const AnimatedText = Animated.createAnimatedComponent(Text)
const AnimatedTouchableOpacity = Animated.createAnimatedComponent(TouchableOpacity)
const AnimatedTouchablWithoutFeedback = Animated.createAnimatedComponent(TouchableWithoutFeedback)

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
		Animated.timing(
			this.state.layoutAnim,
			{
				toValue: 1,
				duration
			}
		).start()
		this.props.setHomeIndex(1)
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
			this.setState({ input: '' })
		}
	}

	onFilterPress() {
		this.props.showFilter(!this.props.filterVisible)
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
				duration
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
				duration
			}
		).start()
		this.props.setHomeIndex(0)
		this.props.showFilter(false)
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
					// onPress={this.onTermSwitcherPress}
					style={switcherContainerStyle}
				>
					<Text style={termTextStyle}>{selectedTerm.term_code}</Text>
					<Icon name="unfold-more" size={20} />
				</TouchableOpacity>
			)
		}

		return (
			<View />
		)
	}

	_renderLeft() {
		const { leftStyle, backStyle } = styles

		const leftContainerWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['20%', '15%']
		})
		const backTextOpacity = this.state.layoutAnim.interpolate({
			inputRange: [0, 0.8, 1],
			outputRange: [0, 0, 1]
		})
		const defaultBtnOpacity = this.state.layoutAnim.interpolate({
			inputRange: [0, 0.8, 1],
			outputRange: [1, 0, 0]
		})
		const activeBtnOpacity = this.state.layoutAnim.interpolate({
			inputRange: [0, 0.8, 1],
			outputRange: [0, 0, 1]
		})

		let button = (
			<TouchableOpacity
				style={[
					leftStyle,
					{
						position: 'absolute',
						left: 0

					}
				]}
				onPress={this.onBackButtonPress}
			>
				<Animated.View
					style={{
						opacity: backTextOpacity
					}}
				>
					<Icon
						name="chevron-left"
						color={COLOR.WHITE}
						size={35}
					/>
				</Animated.View>
				<AnimatedText
					style={[
						backStyle,
						{
							opacity: backTextOpacity
						}
					]}
				>
					Back
				</AnimatedText>
			</TouchableOpacity>
		)

		if (this.props.homeIndex === 1) {
			button = (
				<TouchableOpacity
					style={[
						leftStyle,
						{
							position: 'absolute',
							left: '15%',
						}
					]}
					onPress={this.onCollapseButtonPress}
				>
					<Icon name="chevron-right" color={COLOR.WHITE} size={35} />
				</TouchableOpacity>
			)
		}

		const defaultButton = (
			<AnimatedTouchableOpacity
				style={[
					leftStyle,
					{
						position: 'absolute',
						left: 0,
						opacity: defaultBtnOpacity
					}
				]}
				activeOpacity={0.7}
				onPress={this.onBackButtonPress}
			>
				<Icon
					name="chevron-left"
					color={COLOR.WHITE}
					size={35}
				/>
				<AnimatedText
					style={backStyle}
				>
					Back
				</AnimatedText>
			</AnimatedTouchableOpacity>
		)

		const activeButton = (
			<TouchableWithoutFeedback
				onPress={this.onCollapseButtonPress}
			>
				<Animated.View
					style={[
						leftStyle,
						{
							position: 'absolute',
							left: '15%',
							opacity: activeBtnOpacity
						}
					]}
				>
					<Icon name="chevron-right" color={COLOR.WHITE} size={35} />
				</Animated.View>
			</TouchableWithoutFeedback>
		)

		return (
			<Animated.View
				style={{
					...leftStyle,
					width: leftContainerWidth,
					// borderWidth: 3
					// width: '20%'
				}}
			>
				{defaultButton}
				{activeButton}
			</Animated.View>
		)
	}

	_renderMid() {
		const { input } = this.state
		const { midStyle, searchBarStyle, inputStyle } = styles

		const midContainerWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['80%', '70%']
		})
		const titleWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['80%', '0%']
		})
		const titleLeft = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['38%', '48%']
		})
		const titleColor = this.state.layoutAnim.interpolate({
			inputRange: [0, 0.2, 1],
			outputRange: ['#000000', '#000000', '#FFFFFF']
		})
		const titleOpacity = this.state.layoutAnim.interpolate({
			inputRange: [0, 0.1, 1],
			outputRange: [1, 1, 0]
		})
		const searchBarWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['20%', '100%']
		})

		return (
			<Animated.View
				style={[
					midStyle,
					{
						// borderWidth: 3,
						width: midContainerWidth
					}]}
			>
				<Animated.View
					style={{
						// width: titleWidth,
						position: 'absolute',
						left: titleLeft
					}}
				>
					<AnimatedText
						style={[
							css.navTitle,
							{
								color: COLOR.WHITE,
								opacity: titleOpacity,
								marginTop: -15,
							}
						]}
					>
						{'Webreg'}
					</AnimatedText>
				</Animated.View>
				<Animated.View
					style={{ ...searchBarStyle, width: searchBarWidth, marginRight: this.props.homeIndex ? 0 : 10 }}
				>
					{this._renderTermSwicher()}
					<TextInput
						ref={(ref) => { this.input = ref }}
						style={inputStyle}
						value={input}
						placeholder={this.props.homeIndex ? 'Search by course code' : ''}
						onChangeText={this.onChangeText}
						autoCorrect={false}
						returnKeyType="go"
						onFocus={this.onFocus}
						onSubmitEditing={this.onSubmit}
					/>
					<TouchableWithoutFeedback
						onPress={() => (this.props.homeIndex && this.state.input ? this.setState({ input: '' }) : this.onSearchIconPress)}
					>
						<Icon name={this.props.homeIndex && this.state.input ? 'close' : 'search'} size={24} style={{ paddingVertical: 4 }} />
					</TouchableWithoutFeedback>
				</Animated.View>
			</Animated.View>
		)
	}

	_renderRight = () => {
		const { rightStyle } = styles

		const rightContainerWidth = this.state.layoutAnim.interpolate({
			inputRange: [0, 1],
			outputRange: ['0%', '15%']
		})

		return (
			<Animated.View
				style={{ ...rightStyle, width: rightContainerWidth }}
			>
				<TouchableOpacity
					onPress={this.onFilterPress}
				>
					<Icon name="tune" color={COLOR.WHITE} size={30} />
				</TouchableOpacity>
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
		borderRightWidth: 1,
		borderRightColor: COLOR.DGREY,
		flexDirection: 'row',
	},
	backStyle: {
		color: COLOR.WHITE,
		fontSize: 18
	},
	headerContainerStyle: {
		flexDirection: 'row',
		width: '100%',
		// marginTop: 15,
		// marginBottom: 15,
		justifyContent: 'center',
		alignItems: 'center',
	},
	termTextStyle: {
		color: '#7D7D7D',
		fontSize: 15
	},
	leftStyle: {
		justifyContent: 'center',
		alignItems: 'center',
		flexDirection: 'row',
	},
	midStyle: {
		// flex: 0.72,
		flexDirection: 'row',
		justifyContent: 'flex-end',
		alignItems: 'center'
	},
	searchBarStyle: {
		// flex: 0.72,
		flexDirection: 'row',
		alignItems: 'center',
		borderWidth: 0,
		borderColor: '#194160',
		borderRadius: 20,
		paddingHorizontal: 5,
		backgroundColor: '#F1F1F1'
	},
	inputStyle: {
		flex: 1,
		fontSize: 15,
		paddingLeft: 5,
		paddingRight: 5,
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
	filterVisible: state.webreg.filterVisible,
})

export default withNavigation(connect(mapStateToProps, mapDispatchToProps)(SearchHeader))
