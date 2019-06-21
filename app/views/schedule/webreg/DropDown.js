import {
	TouchableWithoutFeedback,
	View,
	Text,
	TouchableOpacity,
	Platform,
	Button,
	Dimensions,
	Alert
} from 'react-native'
import React from 'react'
import PropTypes from 'prop-types'

import css from '../../../styles/css'

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
 * @props isTermName: boolean
 */
class DropDown extends React.Component {
	renderItem(item, i) {
		const { webreg_dropdown_defaultContainerText, webreg_dropdown_defaultChoiceText } = css

		if (i === 0) {
			return (
				<TouchableOpacity
					onPress={() => this.props.onSelect(item)}
					key={i}
				>
					<View style={[webreg_dropdown_defaultContainerText, { backgroundColor: '#e1e1e1' }]}>
						<Text style={[webreg_dropdown_defaultChoiceText, { color: '#034263' }]}>{item}</Text>
					</View>
				</TouchableOpacity>
			)
		}

		return (
			<TouchableOpacity
				onPress={() => this.props.onSelect(item)}
				key={i}
			>
				<View style={webreg_dropdown_defaultContainerText}>
					<Text style={webreg_dropdown_defaultChoiceText}>{item}</Text>
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
			x, y, cardWidth,
			isTermName
		} = this.props

		const {
			webreg_dropdown_background,
			webreg_dropdown_cancelTrigger,
			webreg_dropdown_overlay,
			webreg_dropdown_dialogContainer,
		} = css

		return (
			<View style={[webreg_dropdown_background, {  height: WINDOW_HEIGHT, width: WINDOW_WIDTH }]}>
				<TouchableWithoutFeedback
					onPress={onCancel}
					style={webreg_dropdown_cancelTrigger}
				>
					<View style={[webreg_dropdown_overlay, { height: WINDOW_HEIGHT, width: WINDOW_WIDTH }]} />
				</TouchableWithoutFeedback>
				<View style={[dialogContainerStyle, { top: y, right: x, width: cardWidth }]}>
					{choices.map((item, i) => isTermName ? this.renderItem(item.term_name, i) : this.renderItem(item.term_code, i))}
				</View>
			</View>
		)
	}
}

DropDown.defaultProps = {
	x: 0,
	y: 0,
	width: 0,
	isTermName: false
}

export default DropDown
