import React, { Component } from 'react'
import {
	View,
	Text,
	TouchableWithoutFeedback,
	TouchableOpacity,
	StyleSheet,
	Animated,
	Easing,
	Image,
	ViewPropTypes
} from 'react-native'
import PropTypes from 'prop-types'
import connect from 'react-redux'

const AnimatedTouchable = Animated.createAnimatedComponent(TouchableOpacity);

class Panel extends Component {
	constructor() {
		// console.log('in Panel Component')
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
			this.props.onProgressUpdate(progress.value)
			this.setState({ progress })
	 })
	}

	componentWillReceiveProps(nextProps) {
		// console.log(this.props.index, 'new props', this.props.selected, nextProps.selected, this.state.expanded)
		if (this.props.selected && !nextProps.selected && this.state.expanded) {
			this.toggle(250)
			this.props.onUpdate(this.state, this.props)
		}
	}

	_setMaxHeight(event) {
		// console.log('in set max height', event.nativeEvent.layout.height)

		this.setState({
			maxHeight: event.nativeEvent.layout.height
		})
	}

	_setMinHeight(event) {
		// console.log('in set min height', event.nativeEvent.layout.height)
		const { height } = event.nativeEvent.layout
		this.setState({
			minHeight: height,
		})
		if (this.state.minHeight === 0) {
			this.state.animatedHeight.setValue(height)
		}
	}

	toggle(duration = 500) {
		// console.log(this.props.index, 'toggling')
		const { expanded, progress, minHeight, maxHeight } = this.state

		const initialValue = expanded ? maxHeight + minHeight : minHeight
		const finalValue = expanded ? minHeight : maxHeight + minHeight

		this.state.animatedHeight.setValue(progress.value)

		// console.log(this.props.index, 'toggling - cont\'d', finalValue)

		if (expanded) {
			Animated.timing(
				this.state.animatedHeight,
				{
					toValue: finalValue,
					duration,
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
					duration,
					easing: Easing.out(Easing.ease)
				}
			).start()
			Animated.timing(
				this.state.animatedColor,
				{
					toValue: 150,
					duration: 500,
				}
			).start(() => {
				// callbacks
			})
		}

		this.setState({
			expanded: !expanded
		})
	}

	render() {
		const { connected, selected, baseColor, animationColor } = this.props

		const interpolateColor = this.state.animatedColor.interpolate({
			inputRange: [0, 150],
			outputRange: [baseColor, animationColor]
		})
		const animatedColorStyle = { backgroundColor: interpolateColor }

		// console.log(this.state.progress, this.state.maxHeight)
		// console.log('animatedColor', animatedColorStyle)
		// console.log(this.state.animatedHeight._val, this.state.progress, this.state.minHeight)

		return (
			<Animated.View style={[styles.container, this.props.containerStyle, { height: this.state.animatedHeight }]}>
				<TouchableWithoutFeedback
					onPress={() => {
						this.props.onClick(this.state, this.props)
						this.toggle()
					}}
					onLayout={this._setMinHeight}
				>
					<Animated.View
						style={[{
							backgroundColor: '#295FA0',
							height: 38,
							width: 316,
							borderTopLeftRadius: 5,
							borderTopRightRadius: 5,
							borderBottomLeftRadius: this.state.progress.value === this.state.minHeight ? 5 : 0,
							borderBottomRightRadius: this.state.progress.value === this.state.minHeight ? 5 : 0,
							alignSelf: 'center',
							justifyContent: 'center',
							alignItems: 'center'
						}, this.props.headerStyle, animatedColorStyle]}
					>
						{this.props.header}
					</Animated.View>
				</TouchableWithoutFeedback>
				<View
					style={[styles.body, this.props.childContainerStyle]}
					onLayout={this._setMaxHeight}
				>
					{this.props.children}
					{/*
						<View
							style={{
								height: 200,
								width: 316,
								alignSelf: 'center',
								backgroundColor: '#FFFFFF',
								flexDirection: 'column',
								justifyContent: 'center'
							}}
						>
							<View
								style={{
									backgroundColor: '#57798A',
									height: 38,
									width: 299,
									borderRadius: 5,
									alignSelf: 'center',
									flexDirection: 'row',
									justifyContent: 'flex-start',
									alignItems: 'center'
								}}
							>
								<Image
									source={EXPAND_ICON}
									style={{ marginLeft: 8, marginRight: 8, flex: 0.1, width: 15, height: 15, resizeMode: 'contain' }}
								/>
								<View style={{ flex: 0.9 }}>
									<AppText style={{ fontSize: 10, marginRight: 8, textAlign: 'left' }}>I'm a guardian who needs to sign documents or approve request</AppText>
								</View>
							</View>
							<View
								style={{
									backgroundColor: '#57798A',
									height: 38,
									width: 299,
									marginTop: 23,
									borderRadius: 5,
									alignSelf: 'center',
									flexDirection: 'row',
									justifyContent: 'flex-start',
									alignItems: 'center'
								}}
							>
								<Image
									source={EXPAND_ICON}
									style={{ marginLeft: 8, marginRight: 8, flex: 0.1, width: 15, height: 15, resizeMode: 'contain' }}
								/>
								<View style={{ flex: 0.9 }}>
									<AppText style={{ fontSize: 10, width: 230 }}>I'm a child who needs to sign documents for school</AppText>
								</View>
							</View>
						</View>*/}
				</View>
			</Animated.View>
		)
	}
}

Panel.propTypes = {
	header: PropTypes.node,
	children: PropTypes.node,
	onClick: PropTypes.func,
	onUpdate: PropTypes.func,
	onProgressUpdate: PropTypes.func,
	connected: PropTypes.bool,
	selected: PropTypes.bool,
	baseColor: PropTypes.string,
	animationColor: PropTypes.string,
	index: PropTypes.number,
	headerStyle: ViewPropTypes.style,
	childContainerStyle: ViewPropTypes.style,
	containerStyle: ViewPropTypes.style,
}

Panel.defaultProps = {
	header: <View />,
	children: <View />,
	onClick: () => {},
	onUpdate: () => {},
	onProgressUpdate: () => {},
	connected: true,
	selected: false,
	baseColor: '#295FA0',
	animationColor: '#47697A',
	index: 0,
	headerStyle: {},
	childContainerStyle: {},
	containerStyle: {}
}

const styles = StyleSheet.create({
	container: {
		marginTop: 15,
		overflow: 'hidden'
	},
	body: {
		padding: 10,
		paddingTop: 0,
		paddingBottom: 0,
	}
})


export default Panel
