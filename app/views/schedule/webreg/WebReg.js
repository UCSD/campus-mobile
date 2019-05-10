import React from 'react'
import { ScrollView, View, Text } from 'react-native'
import { connect } from 'react-redux'

import css from '../../../styles/css'

class WebReg extends React.Component {
	constructor(props) {
		super()
	}

	renderView() {
		const { fullScheduleData } = this.props
		console.log(fullScheduleData)
		return (
			<View>
				<Text>
					{fullScheduleData.data[0].subject_code}
				</Text>
				<Text>
					{fullScheduleData.data[0].course_code}
				</Text>
				<Text>
					{fullScheduleData.data[0].course_title}
				</Text>
			</View>
		)
	}

	render() {
		const { fullScheduleData } = this.props
		let objToReturn
		if (fullScheduleData) {
			objToReturn = (this.renderView())
		} else {
			objToReturn = (<Text>no data here </Text>)
		}
		return (
			<ScrollView
				style={css.scroll_default}
				contentContainerStyle={css.main_full}
			>
				{objToReturn}
			</ScrollView>
		)
	}
}

function mapStateToProps(state) {
	return {
		fullScheduleData: state.schedule.data,
	}
}


export default connect(mapStateToProps)(WebReg)

