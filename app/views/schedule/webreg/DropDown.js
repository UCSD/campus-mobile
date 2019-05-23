import {
	TouchableWithoutFeedback,
	View, Text, TouchableOpacity,
	Platform, Button, Dimensions,
	Alert
} from 'react-native'
import React from 'react'
import PropTypes from 'prop-types'

const WINDOW_WIDTH = Dimensions.get('window').width
const WINDOW_HEIGHT = Dimensions.get('window').height

/**
 * Reusable Component
 * @props choices: Array
 * @props choiceStyle: JSON -- choice text style
 * @props containerStyle: JSON -- container style
 * @props onCancel: function
 * @props onSelect: function
 * @props x: int -- start x
 * @props y: int -- start y
 * @props cardWidth: int
 */
class DropDown extends React.Component {
	renderItem(item, i) {
		const { defaultContainerTextStyle, defaultChoiceTextStyle } = styles

		if (i === 0) {
			return (
				<TouchableOpacity
					onPress={() => this.props.onSelect(item)}
					key={i}
				>
					<View style={[defaultContainerTextStyle, { backgroundColor: '#e1e1e1' }]}>
						<Text style={[defaultChoiceTextStyle, { color: '#034263' }]}>{item}</Text>
					</View>
				</TouchableOpacity>
			)
		}

		return (
			<TouchableOpacity
				onPress={() => this.props.onSelect(item)}
				key={i}
			>
				<View style={defaultContainerTextStyle}>
					<Text style={defaultChoiceTextStyle}>{item}</Text>
				</View>
			</TouchableOpacity>
		)
	}

	render() {
		const {
			choices,
			choiceStyle,
			containerStyle,
			onCancel,
			x, y, cardWidth
		} = this.props

		const {
			backgroundStyle,
			cancelTriggerStyle,
			overlayStyle,
			dialogContainerStyle,
		} = styles

		return (
			<View style={backgroundStyle}>
				<TouchableWithoutFeedback
					onPress={onCancel}
					style={cancelTriggerStyle}
				>
					<View style={overlayStyle} />
				</TouchableWithoutFeedback>
				<View style={[dialogContainerStyle, { top: y, right: x, width: cardWidth }]}>
					{choices.map((item, i) => this.renderItem(item, i))}
				</View>
			</View>
		)
	}
}

const styles = {
	backgroundStyle: {
		position: 'absolute',
		top: 0,
		left: 0,
		height: WINDOW_HEIGHT,
		width: WINDOW_WIDTH
	},
	cancelTriggerStyle: {
		position: 'absolute',
		top: 0,
		left: 0,
	},
	overlayStyle: {
		position: 'absolute',
		backgroundColor: 'black',
		opacity: 0.2,
		height: WINDOW_HEIGHT,
		width: WINDOW_WIDTH
	},
	dialogContainerStyle: {
		position: 'absolute',
		backgroundColor: 'white',
		opacity: 1,
		overflow: 'hidden',
		borderRadius: 10,
		paddingTop: 10,
		paddingBottom: 10,
		shadowOpacity: 0.8,
		shadowOffset: { width: 2, height: 2 },
		shadowColor: 'black',
		shadowRadius: 10,
		elevation: 1
	},
	defaultContainerTextStyle: {
		flex: 1,
		paddingTop: 10,
		paddingBottom: 10,
		backgroundColor: 'white',
		justifyContent: 'center',
	},
	defaultChoiceTextStyle: {
		fontFamily: 'Helvetica Neue',
		fontSize: 18,
		color: '#7D7D7D',
		textAlign: 'center'
	}
}

DropDown.defaultProps = {
	x: 0,
	y: 0,
	width: 0
}

export default DropDown
