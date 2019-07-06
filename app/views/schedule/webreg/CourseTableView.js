/* eslint-disable class-methods-use-this */
import React, { Component } from 'react'
import {
	View,
	Text,
	Image,
	Dimensions,
	TouchableWithoutFeedback,
	Animated,
	Easing,
	FlatList
} from 'react-native'
import Icon from 'react-native-vector-icons/MaterialIcons'
import HeaderRow from './HeaderRow'
import SectionRow from './SectionRow'
import StatusBar from './StatusBar'
import Course from './mockData/Course.json'
import ExpandArrow from './icons8-expand-arrow-filled-500.png'

const { width } = Dimensions.get('screen')

export default class CourseTableView extends Component {

	constructor() {
		super()
		this.state = {
			expanded: false,
			/* Add custom animation and color changes */
			animatedHeight: new Animated.Value(0),
			animatedColor: new Animated.Value(0),
			/* Min and Max height of course table */
			minHeight: 0,
			maxHeight: 0,
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
			console.log(progress.value)
			this.setState({ progress })
		})
	}

	_setLectureStyle() {
		this.setState({ lectureStyle: [{...this.state.lectureStyle}, { height: this.state.animatedHeight }] })
	}

	_setMaxHeight(event) {
		console.log('in set max height', event.nativeEvent.layout.height)

		this.setState({
			maxHeight: event.nativeEvent.layout.height + 7
		})

		this._setLectureStyle()
	}

	_setMinHeight(event) {
		console.log('in set min height', event.nativeEvent.layout.height)
		const { height } = event.nativeEvent.layout
		this.setState({
			minHeight: height + 7,
		})
		this.state.animatedHeight.setValue(height + 7)
	}

	/**
	 * Toggle the discussion sections in a course table.
	 *
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
					console.log('in rendering lectures')
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
					<Icon
						name="play-arrow"
						size={25}
						color="#034263"
						style={[expandIconStyle, expanded && { transform: [{ rotate: '90deg' }] }]}
					/>
				</View>
			</TouchableWithoutFeedback>
		)
	}

	renderEnrollment(section) {
		const { cellWrapperStyle, cellContainerStyle, navIconStyle } = styles
		return (
			<TouchableWithoutFeedback>
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

	renderPrereq() {
		const { cellWrapperStyle, cellContainerStyle, expandIconStyle, prereqTextStyle } = styles
		return (
			<TouchableWithoutFeedback
				// onPress={() => {
				// 	console.log('in rendering course Prerequisites')
				// 	this.toggle()
				// }}
				// onLayout={this._setMinHeight}
			>
				<View style={[cellWrapperStyle, { marginBottom: 12 }]}>
					<View style={cellContainerStyle}>
						<Text style={prereqTextStyle}>Course Prerequisites & Level Restrictions</Text>
					</View>
					<Icon name="play-arrow" size={25} color="#034263" style={expandIconStyle} />
				</View>
			</TouchableWithoutFeedback>
		)
	}

	render() {
		const { containerStyle } = styles
		return (
			<Animated.View
				style={
					[
						containerStyle,
						this.props.style,
					]
				}
			>
				{this.renderPrereq()}
				<Animated.View
					style={this.state.lectureStyle}
				>
					<View style={{ overflow: 'hidden' }} onLayout={this._setMaxHeight}>
					{
						Course.sections.map((sect) => {
							switch (sect.type) {
								case 'LE':
									return this.renderLecture(Course, sect)
								case 'DI':
									// return this.state.expanded && this.renderEnrollment(sect)
									return this.renderEnrollment(sect)
								default:
									// return this.renderAdditionalMeeting(sect)
									return
							}
						})
					}
					{/*<FlatList
						data={Course.sections}
						style={{ overflow: 'hidden' }}
						keyExtractor={({item, index}) => index}
						renderItem={({item, index}) => {
							console.log('section', item, index)
						switch (item.type) {
							case 'LE':
								return this.renderLecture(Course, item)
							case 'DI':
								// return this.state.expanded && this.renderEnrollment(sect)
								return this.renderEnrollment(item)
							default:
								// return this.renderAdditionalMeeting(sect)
								return
						}}}
					/>*/}
					</View>
						{/*
							style={{ flex: 1, flexDirection: 'column' }}

							Course.sections.map((sect) => {
							switch (sect.type) {
								case 'LE':
									return this.renderLecture(Course, sect)
								case 'DI':
									// return this.state.expanded && this.renderEnrollment(sect)
									return this.renderEnrollment(sect)
								default:
									// return this.renderAdditionalMeeting(sect)
									return
							}
						})*/}
				</Animated.View>
				<View>
					{Course.sections.map((sect) => {
						switch (sect.type) {
							case 'LE':
								return
							case 'DI':
								return
							default:
								return this.renderAdditionalMeeting(sect)
						}
					})}
				</View>

			</Animated.View>
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
		transform: [{ rotate: '-90deg' }],
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
	},
	prereqTextStyle: {
		fontSize: 12,
		lineHeight: 14,
		fontWeight: 'bold',
		color: '#034263',
		marginTop: 13,
		marginBottom: 12
	}
}
