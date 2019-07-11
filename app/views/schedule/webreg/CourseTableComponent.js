import React, { Component } from 'react'
import {
	View,
	Image,
	Dimensions,
	TouchableWithoutFeedback,
	Animated,
	Easing
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import { withNavigation } from 'react-navigation'
import HeaderRow from './HeaderRow'
import SectionRow from './SectionRow'
import StatusBar from './StatusBar'
import ExpandArrow from './icons8-expand-arrow-filled-500.png'


const { width } = Dimensions.get('screen')
const AnimatedIcon = Animated.createAnimatedComponent(Icon)

/**
 * @props sectIdx - the index of the lecture section
 * @props course - course data
 */
class CourseTableView extends Component {
	constructor() {
		super()
		this.state = {
			expanded: false,
			/* Add custom animation and color changes */
			animatedHeight: new Animated.Value(0),
			animatedColor: new Animated.Value(0),
			spinValue: new Animated.Value(0),
			/* Min and Max height of course table */
			minHeight: 0,
			maxHeight: 0,
			spin: '180deg',
			/* Keep track of the progress of animated value by adding a listener */
			progress: 0,
			/* Lecture style that will be added the animiated value once
			   our component has mounted */
			lectureStyle: {
				overflow: 'hidden'
			}
		}
		this._onPress = this._onPress.bind(this)
		this._setMaxHeight = this._setMaxHeight.bind(this)
		this._setMinHeight = this._setMinHeight.bind(this)
		this.toggle = this.toggle.bind(this)
		this.state.animatedHeight.addListener((progress) => {
			this.setState({ progress })
		})
	}

	_setLectureStyle() {
		this.setState({ lectureStyle: [{ ...this.state.lectureStyle }, { height: this.state.animatedHeight }] })
	}

	_setMaxHeight(event) {
		this.setState({
			maxHeight: event.nativeEvent.layout.height
		})

		this._setLectureStyle()
	}

	_setMinHeight(event) {
		const { height } = event.nativeEvent.layout
		// Should set the minHeight to be the height of container plus
		// its margin to bottom card
		this.setState({
			minHeight: height + 7,
		})
		this.state.animatedHeight.setValue(height + 7)
	}

	/**
	 * Toggle the discussion sections in a course table.
	 */
	toggle() {
		const initialValue = this.state.expanded ? this.state.maxHeight : this.state.minHeight
		const finalValue = this.state.expanded ? this.state.minHeight : this.state.maxHeight

		this.setState({
			expanded: !this.state.expanded
		})

		this.state.animatedHeight.setValue(initialValue)
		if (this.state.expanded) {
			Animated.timing(
				this.state.animatedHeight,
				{
					toValue: finalValue,
					duration: 500,
					easing: Easing.in(Easing.ease)
				}
			).start()
			Animated.timing(
				this.state.animatedColor,
				{
					toValue: 0,
					duration: 500,
				}
			).start()
			Animated.timing(
				this.state.spinValue,
				{
					toValue: 0,
					duration: 300,
					easing: Easing.linear
				}
			).start()
			this.state.spin = this.state.spinValue.interpolate({
				inputRange: [0, 1],
				outputRange: ['180deg', '90deg']
			})
		} else {
			Animated.timing(
				this.state.animatedHeight,
				{
					toValue: finalValue,
					duration: 500,
					easing: Easing.out(Easing.ease)
				}
			).start()
			Animated.timing(
				this.state.animatedColor,
				{
					toValue: 150,
					duration: 500,
				}
			).start()
			Animated.timing(
				this.state.spinValue,
				{
					toValue: 1,
					duration: 300,
					easing: Easing.linear
				}
			).start()
			this.state.spin = this.state.spinValue.interpolate({
				inputRange: [0, 1],
				outputRange: ['180deg', '90deg']
			})
		}
	}

	_onPress = () => {
		this.setState(prevState => ({
			expanded: !prevState.expanded
		}))
	}

	renderLecture(course, section) {
		const { cellWrapperStyle, cellContainerStyle, dotStyle, expandIconStyle } = styles
		const { expanded } = this.state

		return (
			<TouchableWithoutFeedback
				onPress={() => {
					this.toggle()
				}}
				onLayout={this._setMinHeight}
			>
				<View style={[cellWrapperStyle, { paddingTop: 4, paddingBottom: 7 }]}>
					<View style={dotStyle} />
					<View style={cellContainerStyle}>
						<HeaderRow course={course} />
						<SectionRow data={section} />
					</View>
					<AnimatedIcon
						name="play-arrow"
						size={25}
						color="#034263"
						style={[expandIconStyle, { transform: [{ rotate: this.state.spin }] }]}
					/>
				</View>
			</TouchableWithoutFeedback>
		)
	}

	renderEnrollment(course, section, lectureIdx) {
		const { cellWrapperStyle, cellContainerStyle, navIconStyle } = styles
		return (
			<TouchableWithoutFeedback
				onPress={() => this.props.navigation.navigate('CourseSectionView', { course, diCode: section.sectCode, leIdx: lectureIdx })}
			>
				<View style={cellWrapperStyle}>
					<View style={cellContainerStyle}>
						<SectionRow data={section} style={{ paddingBottom: 3 }} />
						<StatusBar data={section} />
					</View>
					<Image source={ExpandArrow} style={navIconStyle} />
				</View>
			</TouchableWithoutFeedback>
		)
	}

	renderAdditionalMeeting(section) {
		const { cellWrapperStyle, cellContainerStyle, dotStyle } = styles
		return (
			<TouchableWithoutFeedback>
				<View style={cellWrapperStyle}>
					<View style={dotStyle} />
					<View style={cellContainerStyle}>
						<SectionRow data={section} />
					</View>
				</View>
			</TouchableWithoutFeedback>
		)
	}

	render() {
		const { lecIdx, course } = this.props
		let lectureNum = 0
		let finalIdx = 0
		console.log(course);
		return (
			<View style={{ marginBottom: 30 }}>
				<Animated.View
					style={{ overflow: 'hidden', height: this.state.animatedHeight }}
				>
					<View style={{ overflow: 'hidden' }} onLayout={this._setMaxHeight}>
						{
							course.sections.map((sect, index) => {
								console.log(index, lecIdx, lectureNum)
								if (index >= lecIdx && lectureNum <= 1) {
									switch (sect.type) {
										case 'LE':
											lectureNum += 1
											if (lectureNum <= 1) {
												return this.renderLecture(course, sect)
											}
											return
										case 'DI':
											return this.renderEnrollment(course, sect, lecIdx)
										default:
											finalIdx = index
											return
									}
								}
							})
						}
					</View>
				</Animated.View>
				{this.renderAdditionalMeeting(course.sections[finalIdx])}
			</View>
		)
	}
}

const styles = {
	containerStyle: {
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'center',
		overflow: 'hidden'
	},
	cellWrapperStyle: {
		width: width - 32,
		alignSelf: 'center',
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
		marginBottom: 6,
		backgroundColor: '#FBFBFB',
		borderRadius: 10,
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 2
		},
		shadowRadius: 5,
		shadowOpacity: 0.1,
	},
	cellContainerStyle: {
		width: '73%',
		flexDirection: 'column',
		right: 3,
	},
	expandIconStyle: {
		position: 'absolute',
		bottom: 7,
		right: 16,
		transform: [{ rotate: '180deg' }],
	},
	navIconStyle: {
		width: 20,
		height: 20,
		position: 'absolute',
		right: 14,
		tintColor: '#BEBEBE'
	},
	dotStyle: {
		width: 8,
		height: 8,
		borderWidth: 1,
		borderColor: '#034263',
		borderRadius: 4,
		position: 'absolute',
		left: 16,
	}
}


export default withNavigation(CourseTableView);