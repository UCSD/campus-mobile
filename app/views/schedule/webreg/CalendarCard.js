import { Text, View, TouchableOpacity } from 'react-native'
import React from 'react'

import css from '../../../styles/css'

const BORDER_WIDTH = 1
const BORDER_RADIUS = 3
const renderBorder = (selected) => {
	if (selected) {
		return ({
			borderWidth: BORDER_WIDTH,
			borderRadius: BORDER_RADIUS,
			borderColor: '#034263'
		})
	}
	return null
}

/**
 * @props color    - the border color of current class
 * @props name     - the name of class
 * @props location - the location of class
 * @props display  - 'Calendar' or 'Finals' to show
 * @props type     - 'LE' / 'DI' (Only need when display === 'Calendar')
 * @props selected - boolean
 * @props x        - relative postion of x start
 * @props y        - relative postion of y start
 * @props height   - height of card (parsed by time)
 * @props width    - width of card (parsed by Dimensions.width)
 * @props status   - 'enrolled' / 'waitlist' / 'plan'
 * @props onPress  - callback when the course card is pressed
 * @props onLayout - layout information when the course card is first rendered
 * @props zIndex   - if true then the course card is on top of other possible conflicting cards
 */
class CalendarCard extends React.Component {
	componentWillMount() {
		console.log('placeholder for eslint error')
	}

	render() {
		const {
			color,
			name, location,
			display, type,
			selected,
			x, y, height, width,
			status,
			onPress,
			onLayout,
			zIndex
		} = this.props

		let headerColor = '#7D7D7D'
		switch (status) {
			case 'waitlist':
				headerColor = 'red'
				break
			case 'enrolled':
				headerColor = color
				break
			case 'plan':
			default:
				headerColor = '#7D7D7D'
		}

		const {
			webreg_coursecard_container,
			webreg_coursecard_header_container,
			webreg_coursecard_header_text,
			webreg_coursecard_course_container,
			webreg_coursecard_course_text
		} = css

		return (
			<TouchableOpacity
				activeOpacity={1}
				onPress={onPress}
				onLayout={onLayout}
				style={[webreg_coursecard_container,
					{
						left: x - (selected ? BORDER_WIDTH : 0),
						top: y - (selected ? BORDER_WIDTH : 0),
						width: width + (selected ? 2 * BORDER_WIDTH : 0),
						height: height + (selected ? 2 * BORDER_WIDTH : 0),
						zIndex: zIndex ? 1 : 0
					},
					renderBorder(selected)]}
			>
				<View style={[webreg_coursecard_header_container,
					{
						backgroundColor: headerColor
					}]}
				>
					<Text style={webreg_coursecard_header_text}>
						{display === 'Calendar' ? type : display}
					</Text>
				</View>
				<View style={webreg_coursecard_course_container}>
					<Text style={webreg_coursecard_course_text}>{name}</Text>
					<Text style={webreg_coursecard_course_text}>{location}</Text>
				</View>
			</TouchableOpacity>
		)
	}
}

export default CalendarCard
