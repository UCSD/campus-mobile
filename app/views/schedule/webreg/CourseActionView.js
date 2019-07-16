import React from 'react'
import { View, Text, Dimensions, TouchableOpacity, Alert } from 'react-native'
import { withNavigation } from 'react-navigation'
// import { getScreenWidth } from '../../../util/general'

const { width } = Dimensions.get('screen')
const buttons = ['Plan', 'Remove', ['P/NP', 'Letter'], 'Enroll']
const leftStyle = {
	borderTopLeftRadius: 4,
	borderBottomLeftRadius: 4,
}
const rightStyle = {
	borderTopRightRadius: 4,
	borderBottomRightRadius: 4,
}
class CourseActionView extends React.Component {
	onBtnClicked = (title, msg) => {
		Alert.alert(
			title,
			msg,
			[
				{ text: 'Send Email Verification', onPress: () => console.log('email') },
				{ text: 'Back to WebReg',
					onPress: () => {
						this.props.navigation.navigate('WebReg')
						console.log('back')
					},
					style: 'cancel'
				},
			],
		)
	}

	onPlanClicked = () => {
		this.onBtnClicked('Course added to plan', 'CSE 12: added to Fall 2019 plan')
	}

	onRemoveClicked = () => {
		Alert.alert(
			'Remove course from plan?',
			'the action cannot be undone',
			[
				{ text: 'Cancel', onPress: () => console.log('cancel'), style: 'cancel' },
				{ text: 'Remove',
					onPress: () => {
						this.onBtnClicked('Course removed from plan', 'CSE 12: removed from Fall 2019 plan')
					},
					style: 'destructive'
				},
			],
		)
	}

	onEnrollClicked = () => {
		this.onBtnClicked('Course enrolled', 'CSE 12: added to Fall 2019 plan')
	}

	render() {
		const { style } = this.props
		const {
			cellWrapperStyle,
			buttonStyle,
			borderStyle,
			borderReverseStyle,
			buttonTextStyle,
			selectorStyle,
			selectorButtonStyle
		} = styles

		return (
			<View style={[cellWrapperStyle, style, { paddingTop: 7, paddingBottom: 14 }]}>
				{buttons.map((label, index) => {
					switch (index) {
						case 0: case 1:
							return (
								<TouchableOpacity
									style={[buttonStyle, borderStyle]}
									onPress={index === 0 ? this.onPlanClicked : this.onRemoveClicked}
								>
									<Text style={buttonTextStyle}>{label}</Text>
								</TouchableOpacity>
							)
						case 2:
							return (
								<View style={selectorStyle}>
									<TouchableOpacity style={[selectorButtonStyle, borderStyle, leftStyle]}>
										<Text style={buttonTextStyle}>{label[0]}</Text>
									</TouchableOpacity>
									<TouchableOpacity style={[selectorButtonStyle, borderReverseStyle, rightStyle]}>
										<Text style={[buttonTextStyle, { color: '#fff' }]}>{label[1]}</Text>
									</TouchableOpacity>
								</View>
							)
						case 3:
							return (
								<TouchableOpacity
									style={[buttonStyle, borderReverseStyle]}
									onPress={this.onEnrollClicked}
								>
									<Text style={[buttonTextStyle, { color: '#fff' }]}>{label}</Text>
								</TouchableOpacity>
							)
						default: return null
					}
				})}
			</View>
		)
	}
}

const styles = {
	cellWrapperStyle: {
		width,
		paddingHorizontal: width * 0.1,
		flexDirection: 'row',
		flexWrap: 'wrap',
		justifyContent: 'space-between',
		alignSelf: 'center',
		alignItems: 'center',
		backgroundColor: '#FBFBFB',
	},
	buttonStyle: {
		width: '46%',
		height: 30,
		marginTop: 10,
		borderRadius: 4,
		flexDirection: 'row',
		justifyContent: 'space-around',
		alignItems: 'center',
		overflow: 'hidden'
	},
	borderStyle: {
		borderWidth: 1,
		borderColor: '#034263',
	},
	borderReverseStyle: {
		backgroundColor: '#034263',
		color: '#fff'
	},
	buttonTextStyle: {
		fontSize: 13,
		lineHeight: 15,
		color: '#034263'
	},
	selectorStyle: {
		width: '46%',
		height: 30,
		marginTop: 10,
		flexDirection: 'row',
		justifyContent: 'space-around',
		alignItems: 'center',
		overflow: 'hidden'
	},
	selectorButtonStyle: {
		flex: 1,
		height: '100%',
		justifyContent: 'center',
		alignItems: 'center'
	}
}

export default withNavigation(CourseActionView)
