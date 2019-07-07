import React, { Component } from 'react'
import PropTypes from 'prop-types'

import {
	View,
	Text,
  ViewPropTypes,
	TouchableWithoutFeedback,
	StyleSheet,
	Animated,
	Easing,
	Image
} from 'react-native'


/**
 * @props animatedColor    - if given then the backgroundColor of header
 *                           component will change when expanded
 * @props animatedHeight   - if true then the backgroundColor of header
 *                           component will change when expanded
 * @props children         - the child component
 * @props headerComponent  - the header componentWillMount
 * @props duration         - consistent duration for every animation
 * @props icon             - using provided animated icn to toggle component instead
 * @props onPress  - callback when the course card is pressed
 * @props onLayout - layout information when the course card is first rendered
 */
class Panel extends Component {
	constructor() {
		super()
		this.state = {
			expanded: false,
			animatedHeight: new Animated.Value(0),
			animatedColor: new Animated.Value(0),
			minHeight: 0,
			maxHeight: 0,
			progress: 0
		}
		this._setMaxHeight = this._setMaxHeight.bind(this)
		this._setMinHeight = this._setMinHeight.bind(this)
		this.toggle = this.toggle.bind(this)
		this.state.animatedHeight.addListener((progress) => {
			 this.setState({ progress })
	 })
	}

	_setMaxHeight(event) {
		console.log('in set max height', event.nativeEvent.layout.height)

		this.setState({
			maxHeight: event.nativeEvent.layout.height
		})
	}

	_setMinHeight(event) {
		console.log('in set min height', event.nativeEvent.layout.height)
		const { height } = event.nativeEvent.layout
		this.setState({
			minHeight: height,
		})
		this.state.animatedHeight.setValue(height)
	}

	toggle() {
		const initialValue = this.state.expanded ? this.state.maxHeight + this.state.minHeight : this.state.minHeight
		const finalValue = this.state.expanded ? this.state.minHeight : this.state.maxHeight + this.state.minHeight

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

	render() {
		const interpolateColor = this.state.animatedColor.interpolate({
			inputRange: [0, 150],
			outputRange: ['#295FA0', '#47697A']
		})
		const animatedColorStyle = { backgroundColor: interpolateColor }

		console.log('animatedColor', animatedColorStyle)
		console.log(this.state.animatedHeight._val, this.state.progress, this.state.minHeight)

		return (
			<Animated.View style={[styles.container, { height: this.state.animatedHeight }]}>
				<TouchableWithoutFeedback
					onPress={this.props.onPress}
					onLayout={this._setMinHeight}
				>
					<Animated.View>
            {this.props.parent}
					</Animated.View>
				</TouchableWithoutFeedback>
				<View
					style={styles.body}
					onLayout={this._setMaxHeight}
				>
					{this.props.children}
				</View>
			</Animated.View>
		)
	}
}

const defaultStyles = StyleSheet.create({
	container: {
		marginTop: 15,
		overflow: 'hidden'
	},
	body: {
		padding: 10,
		paddingTop: 0
	}
})

Panel.propTypes = {
  animatedColor: PropTypes.string,
  animatedHeight: PropTypes.number,
  children: PropTypes.node.isRequired,
  headerComponent:  PropTypes.node.isRequired,
  duration: PropTypes.number,
  icon: PropTypes.node,
  onPress: PropTypes.func,
  onLayout: PropTypes.func,
  style: PropTypes.object,
}

Panel.defaultProps = {
  animatedColor: null,
  animatedHeight: null,
  children: null,
  headerComponent: null,
  duration: 1000,
  icon: null,
  onPress: null,
  onLayout: null,
  style: defaultStyles,
}

export default Panel
