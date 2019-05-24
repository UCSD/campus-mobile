import { Text, View } from 'react-native'
import React from 'react'

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
	constructor(props) {
		super(props)
	}

	renderBorder(selected) {
		if(selected) {
			return ({
				borderWidth: 1,
				borderRadius: 3,
				borderColor: '#034263'
			})
		}
	}


	render() {
		const {
			color,
			name, location,
			display, type,
			selected,
			x, y, height, width,
			status
		} = this.props

		console.log('x and y', x, y)
		const {
			containerStyle,
			headerContainerStyle,
			headerTextStyle,
			courseContainerStyle,
			courseTextStyle
		} = styles

		var headerColor = '#7D7D7D'
		switch(status) {
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
			<View style={[containerStyle, { left: x, top: y, width, height }, this.renderBorder(selected)]}>
				<View style={{ justifyContent: 'center', backgroundColor: headerColor }}>
					<Text style={headerTextStyle}>{display === 'Calendar' ? type : display}</Text>
				</View>
				<View style={courseContainerStyle}>
					<Text style={courseTextStyle}>{name}</Text>
					<Text style={courseTextStyle}>{location}</Text>
				</View>
			</View>
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
		fontSize: 10,
		textAlign: 'center',
		paddingTop: 2,
		paddingBottom: 2,
		fontFamily: 'Helvetica Neue',
	}
}

export default CourseCard
