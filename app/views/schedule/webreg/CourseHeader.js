import React from 'react'
import {
	TouchableOpacity,
	View,
	StyleSheet
} from 'react-native'
import { withNavigation } from 'react-navigation'
import { connect } from 'react-redux'
import Icon from 'react-native-vector-icons/MaterialIcons'
import CourseTitle from './common/CourseTitle'


class CourseHeader extends React.Component {
	onBackButtonPress = () => {
		this.props.navigation.goBack()
	}

	_renderBackButton = () => {
		const { backButtonStyle } = styles

		return (
			<TouchableOpacity
				style={backButtonStyle}
				onPress={this.onBackButtonPress}
			>
				<Icon name="navigate-before" size={24} color="#ffffff" />
			</TouchableOpacity>
		)
	}

	render() {
		const { course } = this.props
		const { headerContainerStyle, rightButtonStyle } = styles

		return (
			<View
				style={headerContainerStyle}
			>
				{this._renderBackButton()}
				<CourseTitle
					unit={course.UNIT_TO}
					code={`${course.SUBJ_CODE}${course.CRSE_CODE}`}
					title={course.CRSE_TITLE}
					containerStyle={{ flex: 0.72 }}
					fontColor={{ color: '#ffffff' }}
					term={this.props.selectedTerm.term_code}
				/>
				<View style={rightButtonStyle} />
			</View>
		)
	}
}

const styles = StyleSheet.create({
	headerContainerStyle: {
		flexDirection: 'row',
		width: '100%',
		justifyContent: 'center',
		alignItems: 'center',
		backgroundColor: '#034263',
		paddingBottom: 5,
	},
	backButtonStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center'
	},
	rightButtonStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center',
		zIndex: 1000,
	},
})

const mapStateToProps = state => ({
	selectedTerm: state.schedule.selectedTerm
})
export default withNavigation(connect(mapStateToProps)(CourseHeader))
