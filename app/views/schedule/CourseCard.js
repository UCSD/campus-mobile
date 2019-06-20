import React from 'react'
import { View, Text, Dimensions } from 'react-native'

const CARD_WIDTH = Dimensions.get('window').width * 0.85
const CARD_HEIGHT = 50
const PADDING_L = 13
const PADDING_V = 5
const CIRCLE = CARD_HEIGHT - ( PADDING_V * 4 )
/**
 * props:
 * course:{
 *  title:'CSE3',
 *  unit: 4,
 *  description:'Fluency in Information Technology',
 * }
 * term: 'FA19' in the detail page, '' in the search page
 * scale: 0.9 in the detail page, 1 in the search page
 */
class CourseCard extends React.Component {
	constructor(props) {
		super(props)
		this.course = this.props.course
		this.term = this.props.term
		this.scale = this.props.scale
	}

	_getContainerStyle() {
		return {
			width: CARD_WIDTH * this.scale,
			height: CARD_HEIGHT * this.scale,
			paddingLeft: PADDING_L * this.scale,
			borderRadius: ( CARD_HEIGHT / 4 ) * this.scale,
		}
	}

	_getCircleStyle() {
		return {
			width: CIRCLE * this.scale,
			height: CIRCLE * this.scale,
			borderRadius: ( CIRCLE / 2 ) * this.scale,
		}
	}

	_getUnitFontStyle() {
		return {
			fontSize: 20 * this.scale
		}
	}

	_getCourseContainerStyle() {
		return {
			marginLeft: PADDING_L * this.scale,
		}
	}

	_getTitleStyle() {
		return {
			fontSize: 20 * this.scale,
		}
	}

	_getDescriptionStyle() {
		return {
			fontSize: 13 * this.scale,
		}
	}

	_getTermStyle() {
		return {
			right: PADDING_L * this.scale,
			top: PADDING_V * this.scale
		}
	}

	_getTermFontStyle() {
		return {
			fontSize: 13 * this.scale,
		}
	}

	renderTerm() {
		if (this.term !== '') {
			return (
				<View style={[styles.termStyle, this._getTermStyle()]}>
					<Text style={[styles.termFontStyle, this._getTermFontStyle()]}>{this.term}</Text>
				</View>
			)
		}
	}

	render() {
		return (
			<View style={[styles.containerStyle, this._getContainerStyle()]}>
				<View style={[styles.circleStyle, this._getCircleStyle()]}>
					<Text style={[styles.unitFontStyle, this._getUnitFontStyle()]}>
						{this.course.unit}
					</Text>
				</View>
				<View style={[styles.courseContainerStyle, this._getCourseContainerStyle()]}>
					<Text style={[styles.titleStyle, this._getTitleStyle()]}>
						{this.course.title}
					</Text>
					<Text style={this._getDescriptionStyle()}>
						{this.course.description}
					</Text>
				</View>
				{this.renderTerm()}
			</View>
		)
	}
}

const styles = {
	containerStyle: {
		alignSelf: 'center',
		flexDirection: 'row',
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: 'white',
		shadowColor: '#000',
		shadowOffset: {
			width: -0.5,
			height: 2,
		},
		shadowOpacity: 0.10,
		shadowRadius: 1.41,
		elevation: 2,
	},
	circleStyle: {
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: '#EAEAEA',
	},
	unitFontStyle: {
		textAlign: 'center',
	},
	courseContainerStyle: {
		flex: 1,
		flexDirection: 'column',
		justifyContent: 'center',
		alignItems: 'flex-start',
	},
	titleStyle: {
		fontWeight: 'bold'
	},
	termStyle: {
		position: 'absolute',
	},
	termFontStyle: {
		color: 'grey'
	}
}
export default CourseCard