import React from 'react'
import {
	TouchableOpacity,
	View,
	StyleSheet
} from 'react-native'
import { withNavigation } from 'react-navigation'
import Icon from 'react-native-vector-icons/MaterialIcons'
import CourseCell from './CourseCell'


class CourseHeader extends React.Component {
	constructor(props) {
		super(props)
		this.onBackButtonPress = this.onBackButtonPress.bind(this)
	}

	onBackButtonPress() {
		this.props.navigation.goBack()
	}

	_renderBackButton() {
		const { backButtonStyle } = styles

		return (
			<TouchableOpacity
				style={backButtonStyle}
				onPress={this.onBackButtonPress}
			>
				<Icon name="navigate-before" size={24} />
			</TouchableOpacity>
		)
	}

	render() {
		const { headerContainerStyle } = styles

		return (
			<View
				style={[headerContainerStyle, this.props.style]}
			>
				{this._renderBackButton()}
				<CourseCell course={this.props.course} style={{ flex: 0.72 }} />
				<View style={styles.rightButtonStyle} />
			</View>
		)
	}
}

const styles = StyleSheet.create({

	headerContainerStyle: {
		flexDirection: 'row',
		width: '100%',
		// marginTop: 15,
		justifyContent: 'center',
		alignItems: 'center',
		shadowColor: '#000',
		shadowOffset: {
			width: 0,
			height: 1,
		},
		shadowOpacity: 0.1,
		shadowRadius: 2,
	},
	termTextStyle: {
		color: '#7D7D7D',
		fontSize: 15
	},
	backButtonStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center',
	},
	rightButtonStyle: {
		flex: 0.14,
		justifyContent: 'center',
		alignItems: 'center',
	},
})


export default withNavigation(CourseHeader)
