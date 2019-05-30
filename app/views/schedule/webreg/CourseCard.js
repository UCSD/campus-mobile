import { Text, View, TouchableOpacity } from 'react-native'
import React from 'react'

const BORDER_WIDTH = 1
const BORDER_RADIUS = 3
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
 */
class CourseCard extends React.Component {
	renderBorder(selected) {
		if (selected) {
			console.log('course selected', this.props.name)
			return ({
				borderWidth: BORDER_WIDTH,
				borderRadius: BORDER_RADIUS,
				borderColor: '#034263'
			})
		}
		return null
	}

	render() {
		const {
			color,
			name, location,
			display, type,
			selected,
			x, y, height, width,
			status,
			onPress
		} = this.props

		const {
			containerStyle,
			headerTextStyle,
			courseContainerStyle,
			courseTextStyle
		} = styles

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

		return (
			<TouchableOpacity
				activeOpacity={1}
				onPress={onPress}
				style={
					[containerStyle,
						{
							left: x - (selected ? BORDER_WIDTH : 0),
							top: y - (selected ? BORDER_WIDTH : 0),
							width: width + (selected ? 2 * BORDER_WIDTH : 0),
							height: height + (selected ? 2 * BORDER_WIDTH : 0)
						},
						this.renderBorder(selected)]}
			>
				<View style={{
					justifyContent: 'center',
					backgroundColor: headerColor }}
				>
					<Text style={headerTextStyle}>
						{display === 'Calendar' ? type : display}
					</Text>
				</View>
				<View style={courseContainerStyle}>
					<Text style={courseTextStyle}>{name}</Text>
					<Text style={courseTextStyle}>{location}</Text>
				</View>
			</TouchableOpacity>
		)
	}
}

const styles = {
	containerStyle: {
		position: 'absolute',
		backgroundColor: 'white',
		shadowColor: 'black',
		overflow: 'hidden',
		shadowRadius: 2,
		shadowOffset: { width: 2, height: 2 },
		shadowOpacity: 0.8,
		elevation: 1,
		borderRadius: 3
	},
	headerContainerStyle: {
		justifyContent: 'center',
		alignItems: 'center'
	},
	headerTextStyle: {
		paddingTop: 1,
		paddingBottom: 1,
		textAlign: 'center',
		fontWeight: 'bold',
		fontSize: 10,
		fontFamily: 'Helvetica Neue',
	},
	courseContainerStyle: {
		flexDirection: 'column',
		flex: 1,
		justifyContent: 'center',
		alignItems: 'center'
	},
	courseTextStyle: {
		fontSize: 7,
		textAlign: 'center',
		paddingTop: 2,
		paddingBottom: 2,
		fontFamily: 'Helvetica Neue',
	}
}

export default CourseCard
