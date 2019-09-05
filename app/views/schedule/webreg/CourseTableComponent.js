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
			animatedColor: new Animated.Value(0),
			animatedHeight: new Animated.Value(0),
			spinValue: new Animated.Value(0),
			/* Min and Max height of course table */
			minHeight: 0,
			maxHeight: 0,
			spin: '180deg',
			/* Keep track of the progress of animated value by adding a listener */
			/* Lecture style that will be added the animiated value once
			   our component has mounted */
			lectureStyle: {
				overflow: 'hidden'
			}
		}
	}

	_setLectureStyle = () => {
		this.setState({ lectureStyle: [{ ...this.state.lectureStyle }, { height: this.state.animatedHeight }] })
	}

	_setMaxHeight = (event) => {
		this.setState({
			maxHeight: event.nativeEvent.layout.height
		})

		this._setLectureStyle()
	}

	_setMinHeight = (event) => {
		const { height } = event.nativeEvent.layout
		// Should set the minHeight to be the height of container plus
		// its margin to bottom card
		this.setState({
			minHeight: height + 1,
			animatedHeight: new Animated.Value(height + 1)
		})
		// this.state.animatedHeight.setValue(height + 7)
	}

	/**
	 * Toggle the discussion sections in a course table.
	 */
	toggle = () => {
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

	renderLecture = (section) => {
		const { cellWrapperStyle, cellContainerStyle, dotStyle, expandIconStyle } = styles

		return (
			<TouchableWithoutFeedback
				onLayout={this._setMinHeight}
				onPress={this.toggle}
			>
				<View style={[cellWrapperStyle]}>
					<View style={dotStyle} />
					<View style={[cellContainerStyle, { paddingTop: 5, paddingBottom: 10 }]}>
						<HeaderRow course={section} />
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

	renderDiscussion = (section, index) => {
		const { course } = this.props
		const { cellWrapperStyle, cellContainerStyle, navIconStyle } = styles
		return (
			<TouchableWithoutFeedback
				onPress={() => this.props.navigation.navigate('CourseSectionView', { course, index })}
			>
				<View style={cellWrapperStyle}>
					<View style={[cellContainerStyle, { paddingVertical: 2 }]}>
						<SectionRow data={section} style={{ paddingTop: 3 }} />
						<StatusBar data={section} />
					</View>
					<Image source={ExpandArrow} style={navIconStyle} />
				</View>
			</TouchableWithoutFeedback>
		)
	}

	renderFinal = (section) => {
		const { cellWrapperStyle, cellContainerStyle, dotStyle } = styles
		return (
			<TouchableWithoutFeedback>
				<View style={[cellWrapperStyle]}>
					<View style={dotStyle} />
					<View style={[cellContainerStyle, { borderBottomWidth: 0 }]}>
						<SectionRow data={section} />
					</View>
				</View>
			</TouchableWithoutFeedback>
		)
	}


	render() {
		const { course } = this.props
		const leAndDi = course.slice(0, course.length - 1)
		const final = course[course.length - 1]


		return (
			<View style={styles.containerStyle}>
				<Animated.View style={{ overflow: 'hidden', height: this.state.animatedHeight }}>
					<View onLayout={this._setMaxHeight}>
						{
							leAndDi.map((section, index) => {
								switch (section.FK_CDI_INSTR_TYPE) {
									case 'LE':
										if (section.FK_SPM_SPCL_MTG_CD === 'FI') {
											return this.renderFinal(section)
										}
										return this.renderLecture(section)
									case 'DI':
										return this.renderDiscussion(section, index)
									default:
										break
								}
								return null
							})
						}
					</View>
				</Animated.View>
				{this.renderFinal(final)}
			</View >
		)
	}
}

const styles = {
	containerStyle: {
		flexDirection: 'column',
		justifyContent: 'flex-start',
		alignItems: 'center',
		overflow: 'hidden',
		backgroundColor: '#FBFBFB',
		borderRadius: 10,
		borderWidth: 1,
		borderColor: 'rgba(0, 0, 0, 0.1)',
		marginBottom: 12,
	},
	cellWrapperStyle: {
		width: width - 32,
		alignSelf: 'center',
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
	},
	cellContainerStyle: {
		width: '73%',
		flexDirection: 'column',
		right: 3,
		borderBottomWidth: 1,
		borderColor: 'rgba(190, 190, 190, 0.5)',
		// paddingBottom: 6,
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


export default withNavigation(CourseTableView)